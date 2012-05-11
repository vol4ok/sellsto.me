require('coffee-script');
var User = require('../app/models/user').User;
var defer = require("node-promise").defer;
var Range = require('./generator').Range;
var msgType = require('./message_types');
var generator = require('./generator');
var util = require('util');

var entriesCount = 500000;
var executed = 0;
var toDelete = new Array();
var sessionIds = new Array();

function log(msg) {
    process.send({type: msgType.Log, log: msg});
}

log('child process started');

//Phase 1 populate a mongodb database
function populateDB(err, deferred) {
    function tick() {
        var user = new User();
        user.email = generator.randomString(10);
        user.password = generator.randomString(6);
        user.sessionId = generator.randomString(30);
        user.save(function(err, doc) {
            if (err) {
                populateDB(err, deferred);
            } else {
                toDelete.push(doc._id);
                sessionIds.push(doc.sessionId);
                populateDB(undefined, deferred); //continuation style
            }
        });
    }

    if (executed % 10000 === 0) {
        log('executed: '+executed);
    }

    if (executed < entriesCount) {
        if (err) {
            deferred.reject(err);
        } else {
            executed++;
            process.nextTick(tick);
        }
    } else {
        deferred.resolve();
    }

    return deferred.promise;
}

var start = null;
var end = null;
var hasError = false;
function bench() { //does the actual benchmarks
    var deferred = defer();
    function selectSession() {
        var elementIndex = generator.nextInt(sessionIds.length);
        return sessionIds[elementIndex];
    }
    start = new Date().getTime();

    process.on('message', function(msg) {
        if (msg.type && msg.type === msgType.Tick && !hasError) {
            var isFinal = msg.isFinal === true;
            var sessionId = selectSession();
            User.find({sessionId: sessionId}, function(err, doc) {
                if (err) {
                    console.log('error during bench: '+util.inspect(err));
                    hasError = true;
                    deferred.reject(err);
                }

                if (isFinal) {
                    end = new Date().getTime();
                }
            });
        } else {
            hasError = true;
        }
    });

    return deferred.promise;
}

//Cleanup the database
function cleanUP(err, deferred) {
    function tick() {
        User.remove({_id: toDelete[0]}, function(err) {
            if (err) {
                cleanUP(err, deferred);
            } else {
                cleanUP(undefined, deferred);
            }
            toDelete.splice(0, 1); //remove the first element
        });
    }

    if (toDelete.length > 0) {
        if (err) {
            deferred.reject(err);
        } else {
            process.nextTick(tick);
        }
    } else {
        deferred.resolve();
    }

    return deferred.promise;
}

populateDB(undefined, defer()).then(
function() { //success callback
    process.send({type: msgType.InitComplete });
    return bench();
}).then(
function() { //success callback
    process.send({type: msgType.BenchComplete});
    return cleanUP(undefined, defer());
}).then(
function() {
    process.send({type: msgType.CleanupComplete});
},
function(err) { //indicate that error occurred during executing a given request
    process.send({type: msgType.Err, err: JSON.stringify(err)});
});