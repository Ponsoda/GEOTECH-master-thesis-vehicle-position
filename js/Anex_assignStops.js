//Requere tools
var time = require('node-tictoc');
var MongoClient = require('mongodb').MongoClient;

//Define variables
var dbName="admin";
var hostName="localhost";
var port="27017";
var collectionPoints = "emt_buses";
var collectionViales = "castellana";
var collectionStops = 'stopsCollection';
var stopsJoinName ="stops";
var pointsJoinName="bus_points"

MongoClient.connect("mongodb://"+hostName+":"+port+"/"+dbName+"?keepAlive=true&socketTimeoutMS=6000000", { useUnifiedTopology: true }, async function (err, db) {
    if (err) throw err;
    time.tic();
    var dbo = db.db(dbName);
    var vialesCursor = dbo.collection(collectionViales).aggregate([
        {$lookup:
            {from: collectionStops,
                let: { vialId_local: "$properties.LinkId", sentido_local: "$properties.Sentido"},
                 pipeline: [                 
                    {$match:
                        {$expr:
                            {$and:
                                [
                                    {$eq:["$properties.IDVial", "$$vialId_local"]},
                                    {$eq:["$properties.Sentido", "$$sentido_local"]}
                                ]
                             }
                         }
                    }
                ],
                as: stopsJoinName
            }
        },
          {$match:{"stops":{"$ne":[]}}},
          {
            $lookup:
            {from: collectionPoints,
                let: { lineaId_local: "$properties.NumLinea", sentido_local: "$properties.Sentido", cumulativeMeters_local: "$properties.Cum_Length", sectionMeters_local:"$properties.Shape_Length"},
                pipeline: [
                  {$match:{speed:{$exists:true}}},
                    { $match:
                        { $expr:
                            { $and:
                                [
                                    {$eq:[ "$linea",  "$$lineaId_local" ]},
                                    {$eq: [ "$ruta", "$$sentido_local" ]},
                                    {$and:
                                        [{$gte:[ "$meters","$$cumulativeMeters_local"]}, 
                                            {$lt:
                                                [
                                                 "$meters",
                                                    {$sum:["$$cumulativeMeters_local", "$$sectionMeters_local"]}
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        }
                    }
                ],
                  as: pointsJoinName
            }    
        },
         { $match:{"bus_points":{"$ne":[]}}}
    ])

    var addVialCount=1;
    while(await vialesCursor.hasNext()){
      var vialHere = await vialesCursor.next();    
        for (let i = 0; i < vialHere.bus_points.length; i++) {
            lineaId=vialHere.bus_points[i].linea
            var both = vialHere.stops.map(x=>x.properties.CodLineaSA).includes(lineaId);
            if(both){
                var index=vialHere.stops.properties.CodeLineaSA.indexOf(lineaId);                    
            await dbo.collection(collectionPoints).updateOne({
                  _id: vialHere.bus_points[i]._id        
                }, {
                        $set:{
                         "stop": vialHere.bus_points[index].properties.IdParadaFi
                        }        
                    },                                          
                )
                .then(function(){ 
                        console.log(this); return;
                }.bind(addVialCount++)) 
            }
        }                                              
    }    
     console.log("Done")
     time.toc();
})