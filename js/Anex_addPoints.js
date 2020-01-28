//Require tools
var mongoose = require("mongoose");
mongoose.set('useCreateIndex', true);
var axios = require('axios');
var GeoJSON = require('mongoose-geojson-schema');

//Define variables
var dbName="admin";
var hostName="localhost";
var port="27017";
var collectionName= "emt_buses"
var emtEmail= "iponsodal@co.idom.com";
var emtPassword= "busesEmt1";

//Post request filter in JSON
var jsonRequest =`{"$or":[{"linea":5},{"linea":7},{"linea":12},{"linea":14},{"linea":16},{"linea":27},
                  {"linea":40},{"linea":45},{"linea":126},{"linea":147},{"linea":150}],"status":"5"}`; 
                   
var intervalTime=16500

mongoose.connect("mongodb://"+hostName+":"+port+"/"+dbName, {useNewUrlParser: true, useUnifiedTopology: true});
var db = mongoose.connection;
db.on("error", console.error.bind(console, "connection error"));
db.once("open", function(callback) {
     console.log("Connection succeeded.");
});
var Schema = mongoose.Schema;
var dataArraySchema = new Schema({
    uniqueId: {
        type: String,
        "default":function(){
            return (String(this.bus)+this.dateExpired.date)
        }
    },
    status: Number,
    linea: Number,
    bus: Number,
    meters: Number,
    utmX: Number, 
    utmY: Number,
    ruta: Number,
    lineaFecha: String,
    codigoparada: Number,
    geometry: GeoJSON,
    dateExpired:{
        date: Number
    },
    time: {
        type: Date,
        "default":function(){
            return (this.dateExpired.date)
        }
    }
});
var mainSchema = new Schema({
    data: [dataArraySchema]
});
mainSchema.index({ uniqueId: 1},{unique:true})
var collectionModel = mongoose.model(collectionName, mainSchema);
function onInsert(err, docs) {
    if (err) {
    } else {     
        console.info('Document added.');
    }
}

function callApiRest() {
    console.log("Get Call") 
    axios({
        method: 'get',
        url: 'https://openapi.emtmadrid.es/v1/mobilitylabs/user/login/',
        headers: {
            "email": emtEmail,
            "password": emtPassword
        }
    })
        .then(function(response) {
            setInterval(function(){ 
                console.log("New call")
                callCollection(response.data.data[0].accessToken)
            }, intervalTime);

        })
        .catch(function(error) {
            console.log("Get problem")
            console.log(error);
        });
 }

function callCollection(accessToken) {  
    axios({
        method: 'post',
        url: "https://openapi.emtmadrid.es/v1/mobilitylabs/collection/reactive/ff594c7a-8a7c-423a-8a06-c14a4fac5bff/2/",
        headers: {
            "accessToken": accessToken,
            "Content-Type": "application/json"
        },  
        data: jsonRequest
    })
        .then(function(response) {
            var filteredRequest = new collectionModel(JSON.parse(JSON.stringify(response.data).replace(new RegExp("\\$","g"),"")));           
            collectionModel.collection.insertMany(filteredRequest.data, onInsert, { ordered: false })
            if(response.data.code==80){
                console.log("Error token")
                callApiRest()
            }
        })
        .catch(function(error) {
            console.log(error);
        });
}

callApiRest()
