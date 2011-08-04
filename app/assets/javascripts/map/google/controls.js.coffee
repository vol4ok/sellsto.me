# This file would be used for implementing sellstome Google Map overlays
# We currently using v3 Google map javascript API
# @author Zhugrov Aliaksandr

namespace "sellstome.googlemap.controls", (() ->

  RadiusSelector = ( circleOverlay ) ->
    container = document.createElement "div"
    jQuery("<img style='width: 19px; height: 42px; -webkit-user-select: none; border-top-width: 0px;
                 border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial;
                 border-color: initial; padding-top: 0px; padding-right: 0px; padding-bottom: 0px;
                 padding-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;'
                 src='http://maps.gstatic.com/intl/ru_ru/mapfiles/szc3d.png'>").appendTo container
    radiusPlusButton = jQuery("<div style='position: absolute; left: 0px; top: 0px; width: 19px; height: 21px; cursor: pointer;'
                   title='+'></div>").appendTo container
    radiumMinusButton = jQuery("<div style='position: absolute; left: 0px; top: 21px; width: 19px; height: 21px; cursor: pointer;'
                            title='-'>").appendTo container
    # attach control events
    google.maps.event.addDomListener radiusPlusButton.get(0)  ,"click", () ->
      circleOverlay.setRadius circleOverlay.getRadius() * 1.25

    google.maps.event.addDomListener radiumMinusButton.get(0) ,"click", () ->
      circleOverlay.setRadius circleOverlay.getRadius() * 0.8

    return container

  return {
    RadiusSelector: RadiusSelector
  }
)()