/**
 * Adobe Edge: symbol definitions
 */
(function($, Edge, compId){
//images folder
var im='images/';

var fonts = {};


var resources = [
];
var symbols = {
"stage": {
   version: "1.0.0",
   minimumCompatibleVersion: "0.1.7",
   build: "1.0.0.185",
   baseState: "Base State",
   initialState: "Base State",
   gpuAccelerate: false,
   resizeInstances: false,
   content: {
         dom: [
         {
            id:'background',
            type:'image',
            rect:['0px','-900px','320px','900px','auto','auto'],
            fill:["rgba(0,0,0,0)",im+"background.png",'0px','0px']
         },
         {
            id:'Text',
            type:'text',
            rect:['-96','-232','auto','auto','auto','auto'],
            text:"e-fon",
            font:['Arial, Helvetica, sans-serif',24,"rgba(0,0,0,1)","normal","none",""]
         },
         {
            id:'title',
            type:'image',
            rect:['44px','179px','231px','100px','auto','auto'],
            fill:["rgba(0,0,0,0)",im+"title.png",'0px','0px']
         }],
         symbolInstances: [

         ]
      },
   states: {
      "Base State": {
         "${_Stage}": [
            ["color", "background-color", 'rgba(255,255,255,1)'],
            ["style", "overflow", 'hidden'],
            ["style", "height", '480px'],
            ["style", "width", '320px']
         ],
         "${_background}": [
            ["style", "top", '-891px'],
            ["style", "left", '0px'],
            ["style", "height", '884px']
         ],
         "${_title}": [
            ["style", "left", '44px'],
            ["style", "top", '179px']
         ]
      }
   },
   timelines: {
      "Default Timeline": {
         fromState: "Base State",
         toState: "",
         duration: 15310,
         autoPlay: true,
         timeline: [
            { id: "eid2", tween: [ "style", "${_background}", "top", '0px', { fromValue: '-891px'}], position: 0, duration: 15310, easing: "easeInCubic" },
            { id: "eid5", tween: [ "style", "${_background}", "left", '0px', { fromValue: '0px'}], position: 0, duration: 0 }         ]
      }
   }
}
};


Edge.registerCompositionDefn(compId, symbols, fonts, resources);

/**
 * Adobe Edge DOM Ready Event Handler
 */
$(window).ready(function() {
     Edge.launchComposition(compId);
});
})(jQuery, AdobeEdge, "EDGE-383172949");
