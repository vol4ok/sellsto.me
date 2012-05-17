// a simple executor for async benchmarks
// for now it will be hardcoded for a mongoose_bench.coffee file
require('coffee-script');
var cp = require('child_process');
var util = require('util');
var $ = require('core.js');
var msgType = require('./message_types');

var n = cp.fork(__dirname+'/redis_bench.js');
n.on('exit', function(data) {
    console.log("exited from child process");
});
console.log('master process has forked a child process');

n.on('message', function(msg) {
    if ($.isUndefined(msg.type)) throw new Error('Received an invalid message from benchmark script');
    switch(msg.type) {
        case msgType.InitComplete:
            console.log('Receive init complete. Starting benchmark.');
            startBench(); //init main benchmark
            break;
        case msgType.BenchComplete:
            console.log('Bench complete in time: '+msg.time+' millis');
            break;
        case msgType.CleanupComplete:
            console.log('Cleanup complete');
            break;
        case msgType.Err:
            console.log('Error occurred: '+msg.err);
            break;
        case msgType.Log:
            console.log(msg.log);
            break;
        default:
            throw new Error('Unknown message type: '+msg.type);
    }
});

var startBench = function() {
    console.log('starting emulating requests');
    var i = 0;
    function sendRequest() {
        if (i % 100 === 0) {
            console.log('Sending requests: '+i);
        }
        if (i < 1000) {
            n.send({type: msgType.Tick, isFinal: false}); //here we simulate an external requests
            process.nextTick(sendRequest); //unwind stack.
        } else {
            n.send({type: msgType.Tick, isFinal: true}); //indicate that this is a final request
        }
        i++;
    }
    process.nextTick(sendRequest);
};