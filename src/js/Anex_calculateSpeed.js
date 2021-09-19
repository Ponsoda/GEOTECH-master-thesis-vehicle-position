//Requere tools
var MongoClient=require('mongodb').MongoClient;

//Define variables
var dbName="emtdb";
var hostName="localhost";
var port="27017";
var collectionPoints = "complete";

MongoClient.connect("mongodb://"+hostName+":"+port+"/"+dbName,{ useUnifiedTopology: true }, function(err, db) {
    if (err) throw err;
    var dbo = db.db(dbName);
    dbo.collection(collectionPoints)
    .distinct("bus")
    .then((uniqueBusIds) =>uniqueBusIds
    .forEach(function(busId){
        var timeActualBus=0;
        var timeLastBus=0;
        var metersActualBus=0;
        var metersLastBus=0;      
        var cursorBusId=0;
        var differenceTime=0;
        var differenceMeters=0;
        var speedBus=0;
        var codParada=0;
        var busCursor=dbo.collection(collectionPoints).find({bus:busId}).sort({"dateExpired.date":1}).addCursorFlag('noCursorTimeout',true);
        
        busCursor.forEach(function(busPoint) {
            if(cursorBusId!=busPoint.bus){
                timeActualBus=0;
                metersActualBus=0;
                cursorBusId=busPoint.bus
                timeLastBus=busPoint.dateExpired.date
                metersLastBus=busPoint.meters
                codParada=busPoint.codigoparada
                unL=busPoint.uniqueId
            }else{
                timeActualBus=busPoint.dateExpired.date
                metersActualBus=busPoint.meters
                differenceTime=((timeActualBus-timeLastBus)/3600000)
                differenceMeters=((metersActualBus-metersLastBus)/1000)                  
                timeLastBus=timeActualBus
                metersLastBus=metersActualBus
                    
                if(differenceMeters<0 || isNaN(differenceMeters/differenceTime) || !isFinite(differenceMeters/differenceTime) || differenceTime>0.016||codParada!=busPoint.codigoparada&&differenceMeters/differenceTime>50){
                    codParada = busPoint.codigoparada
                }else{
                    speedBus=differenceMeters/differenceTime
                    dbo.collection(collectionPoints).updateOne({
                         _id:busPoint._id 
                    }, 
                        {$set: 
                            {    
                                "speed": speedBus  
                             }
                        }, function(err, res) {                            
                                if (err) throw err;  
                        }
                    );
                    console.log("speed: "+speedBus)
                }
            }
        })
    }))        
});
     
  

 
 
