<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="OlMapApp.Index" %>
<!DOCTYPE html>
<html>
    <head>
    <title>District and Places on map</title>
    <link rel="stylesheet" href="https://openlayers.org/en/v4.6.5/css/ol.css" type="text/css">
    <script src="https://cdn.polyfill.io/v2/polyfill.min.js?features=requestAnimationFrame,Element.prototype.classList,URL"></script>
    <script src="https://openlayers.org/en/v4.6.5/build/ol.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

    <style>
        .ol-popup {
        position: absolute;
        background-color: lightgoldenrodyellow;
        -webkit-filter: drop-shadow(0 1px 4px rgba(0,0,0,0.2));
        filter: drop-shadow(0 1px 4px rgba(0,0,0,0.2));
        padding: 15px;
        border-radius: 10px;
        border: 1px solid #cccccc;
        bottom: 12px;
        left: -50px;
        min-width: 180px;
        }
        .ol-popup:after, .ol-popup:before {
        top: 100%;
        border: solid transparent;
        content: " ";
        height: 0;
        width: 0;
        position: absolute;
        pointer-events: none;
        }
        .ol-popup:after {
        border-top-color: white;
        border-width: 10px;
        left: 48px;
        margin-left: -10px;
        }
        .ol-popup:before {
        border-top-color: #cccccc;
        border-width: 11px;
        left: 48px;
        margin-left: -11px;
        }
        .ol-popup-closer {
        text-decoration: none;
        position: absolute;
        top: 2px;
        right: 8px;
        }
        .ol-popup-closer:after {
        content: "✖";
        }
 
    </style>
    </head>
    <body>

    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.12.1/bootstrap-table.min.css">
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.12.1/bootstrap-table.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.12.1/locale/bootstrap-table-zh-CN.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/jspanel.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/jspanel.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/extensions/modal/jspanel.modal.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/extensions/tooltip/jspanel.tooltip.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/extensions/hint/jspanel.hint.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/extensions/layout/jspanel.layout.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/extensions/contextmenu/jspanel.contextmenu.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/jspanel4@4.0.0/dist/extensions/dock/jspanel.dock.js"></script>
       
    <div id="map" class="map"></div>
    <div id="popup" class="ol-popup">
        <a href="#" id="popup-closer" class="ol-popup-closer"></a>
        <div id="popup-content"></div>
    </div>

    <form id="options-form" automplete="off">
        <table class="table">
            <tbody>
                <tr>
                    <th scope="row"><input type="button" value="SEARCH" id="searchButton"/></th>
                    <td> <input type="radio" name="interaction" value="drawDistrict" id="drawDistrict" >Draw District</td>
                    <td> <input type="radio" name="interaction" value="markPlace" id="markPlace" >Mark Place</td>
                    <td> <input type="radio" name="interaction" value="select"checked>Select</td>
                </tr>
            </tbody>
        </table>
    </form>

    <script>
        var container = document.getElementById('popup');
        var content = document.getElementById('popup-content');
        var closer = document.getElementById('popup-closer');
        var optionsForm = document.getElementById('options-form');

        var lastClick = false;
        var vectorDistrict = null;
        var selectedObj = null;
        var districtCode = 0;
        var statusPop = null;
        var selectedFeatureID = 0;
        var wktCoordinate;
        var featureID = 0;
        var showPop = false;
        var urlDistrict = "/DataProccess.ashx?f=GetDistricts";
        var urlPlace = "/DataProccess.ashx?f=GetPlaces";
        var districtArray = [];
        var lastfea = null;

        $.ajax({
            url: urlDistrict,
            success: function (result) {
                var sonuc = JSON.parse(result);
                var format = new ol.format.WKT();
                districtCode = sonuc.length;
                for (var i = 0; i < sonuc.length; i++) {
                    var feature = format.readFeature(sonuc[i].DistrictWkt, {
                        dataProjection: 'EPSG:4326',
                        featureProjection: 'EPSG:3857'
                    });
                    feature.set('DistrictName', sonuc[i].DistrictName);
                    feature.set('DistrictCode', sonuc[i].DistrictCode);
                    districtArray.push(feature);
                }
            }
        });
        
        $.ajax({
            url: urlPlace,
            success: function (result) {
                var sonuc = JSON.parse(result);
                var format = new ol.format.WKT();
                for (var i = 0; i < sonuc.length; i++) {
                    var feature = format.readFeature(sonuc[i].PlaceCoord, {
                        dataProjection: 'EPSG:4326',
                        featureProjection: 'EPSG:3857'
                    });
                    feature.set('PlaceNo', sonuc[i].PlaceNo);
                    feature.set('DistrictCode', sonuc[i].DistrictCode);
                    districtArray.push(feature);
                }
                vectorDistrict = new ol.layer.Vector({
                    source: new ol.source.Vector({
                        features: districtArray
                    })
                });
                map.addLayer(vectorDistrict);
            }
        });
        
        var raster = new ol.layer.Tile({
            source: new ol.source.BingMaps({
                key: 'AnKlDZi3RroVDKa4dT-96Or6DQD9ZqRNNdTlE3Sz2i919ph-QANW2JI1EmeL357F',
                imagerySet: 'AerialWithLabels'
            })
        });

        var vector = new ol.layer.Vector({ 
            source: new ol.source.Vector(),
            style: new ol.style.Style({
                    fill: new ol.style.Fill({
                        color: 'rgba(255, 255, 255, 0.2)'
                    }),
                    stroke: new ol.style.Stroke({
                    color: '#ffcc33',
                    width: 2
                }),
                image: new ol.style.Circle({
                    radius: 7,
                    fill: new ol.style.Fill({
                        color: '#ffcc33'
                    })
                })
            })
        });

        var overlay = new ol.Overlay({
            element: container,
            autoPan: true,
            autoPanAnimation: {
                duration: 250
            }
        });

        var map = new ol.Map({
            layers: [raster, vector],
            target: 'map',
            overlays: [overlay],
            view: new ol.View({
                center: ol.proj.transform([34.200, 38.800], "EPSG:4326", "EPSG:3857"),
                zoom: 6
            })
        });

        closer.onclick = function () {
            if (statusPop == 'district') {
                selectedFeatureID = districtCode;
                var features = vector.getSource().getFeatures();
                for (item in features) {
                    var id = features[item].getProperties().DistrictCode;
                    if (id == selectedFeatureID) {
                        vector.getSource().removeFeature(features[item]);
                        districtCode -= 1;
                        break;
                    }
                }
            }
            else if(statusPop == 'place') {
                selectedFeatureID = featureID;
                var features = vector.getSource().getFeatures();
                for (item in features) {
                    var id = features[item].getProperties().id;
                    if (id == selectedFeatureID) {
                        vector.getSource().removeFeature(features[item]);
                        break;
                    }
                }
            }
            hidePopup();
        };

        function hidePopup() {
            overlay.setPosition(undefined);
            closer.blur();
            return false;
        }

        var markPlace = {
            init: function () {
                map.addInteraction(this.Point);
                this.Point.setActive(false);
            },
            Point: new ol.interaction.Draw({
                source: vector.getSource(),
                type: 'Point'
            }),
            getActive: function() {
                return this.activeType ? this[this.activeType].getActive() : false;
            },
            setActive: function(active) {
                var type = 'Point';
                if (active) {
                    this.activeType && this[this.activeType].setActive(false);
                    this[type].setActive(true);
                    this.activeType = type;
                } else {
                    this.activeType && this[this.activeType].setActive(false);
                    this.activeType = null;
                }
            }
        };
        markPlace.init();

        var drawDistrict = {
            init: function () {
                map.addInteraction(this.Polygon);
                this.Polygon.setActive(false);
            },
            Polygon: new ol.interaction.Draw({
                source: vector.getSource(),
                type: 'Polygon'
            }),
            getActive: function () {
                return this.activeType ? this[this.activeType].getActive() : false;
            },
            setActive: function (active) {
                var type = 'Polygon';
                if (active) {
                    this.activeType && this[this.activeType].setActive(false);
                    this[type].setActive(true);
                    this.activeType = type;
                } else {
                    this.activeType && this[this.activeType].setActive(false);
                    this.activeType = null;
                }
            }
        };
        drawDistrict.init();

        var Select = {
            init: function () {
                this.select = new ol.interaction.Select();
                map.addInteraction(this.select);
            },
            setActive: function(active) {
                this.select.setActive(active);
            }
        };
        Select.init();

        optionsForm.onchange = function(e) {
            var type = e.target.getAttribute('name');
            var value = e.target.value;
            if (type == 'interaction') {
                if (value == 'select') {
                    markPlace.setActive(false);
                    drawDistrict.setActive(false);
                    Select.setActive(true);
                } else if (value == 'markPlace') {
                    hidePopup();
                    markPlace.setActive(true);
                    drawDistrict.setActive(false);
                    Select.setActive(false);
                }
                else if (value == 'drawDistrict') {
                    hidePopup();
                    drawDistrict.setActive(true);
                    markPlace.setActive(false);
                    Select.setActive(false);
                }
            }
        };

        markPlace.setActive(false);
        drawDistrict.setActive(false);
        Select.setActive(true);

        var snap = new ol.interaction.Snap({
            source: vector.getSource()
        });
        map.addInteraction(snap);
        
        function writeDatabase() {
            if (polygon.getActive()==true) {
                var districtName = $("#txtDistrictName").val();
                var url = "/DataProccess.ashx?f=AddDistrict&DistrictName=" + districtName + "&DistrictWkt=" + wktCoordinate + "&DistrictCode=" + districtCode;
                $.ajax({
                    url: url,
                    success: function (result) {
                        alert(result);
                        hidePopup();
                        lastfea.setProperties({
                            'DistrictName': districtName
                        })
                    }
                });
            } else {
                var placeNo = $("#txtPlaceNo").val();
                var url = "/DataProccess.ashx?f=AddPlace&PlaceNo=" + placeNo + "&PlaceCoord=" + wktCoordinate + "&DistrictCode=" + selectedObj;
                $.ajax({
                    url: url,
                    success: function (result) {
                        alert(result);
                        hidePopup();
                    }
                });
            }
        };

        map.on('singleclick', function (evt) {
            var coordinate = evt.coordinate;
            coord = ol.proj.transform(coordinate, 'EPSG:3857', 'EPSG:4326');
            if (markPlace.getActive() == true && showPop == true) {       
                content.innerHTML = 'Add a new place <br>'+
                    '<input id="txtPlaceNo" type="text" placeholder="Place no"></input><br><center>' +
                    '<input type="button" class="popclass" value="Cancel" onclick="closer.onclick()" />' +
                    '<input type="button" class="popclass" value="Save" onclick="writeDatabase();" /><br>';
                overlay.setPosition(coordinate);
                statusPop = 'place';
            } else if (markPlace.getActive() == true && showPop == false) {
                statusPop = 'place';
                closer.onclick();
            } else if (markPlace.getActive() != true && lastClick == true) {
                content.innerHTML = 'Add a new district <br>'+
                    '<input id="txtDistrictName" type="text" placeholder="District name"></input><br>' +
                    '<input type="button" value="Cancel" onclick="closer.onclick()" />' +
                    '<input type="button" value="Save" onclick="writeDatabase();" />';
                overlay.setPosition(coordinate);
                lastClick = false;
                statusPop = 'district';
            } else if (drawDistrict.getActive() == false && markPlace.getActive() == false) {
                Select.select.getFeatures().on("add", function (e) { 
                    var DistrictName = e.element.getProperties().DistrictName;
                    var DistrictCode = e.element.getProperties().DistrictCode;
                    var PlaceNo = e.element.getProperties().PlaceNo;
                    if (DistrictName != undefined) 
                        content.innerHTML = 'District name : ' + DistrictName + '<br>District code : ' + DistrictCode;
                    else 
                        content.innerHTML = 'Place No : ' + PlaceNo + '<br>District Code : ' + DistrictCode;
                    overlay.setPosition(coordinate);
                });
                
            }
            showPop = false;
        });
        
        var point = markPlace.Point;
        var polygon = drawDistrict.Polygon;

        point.on('drawend', function (e) {
            var format = new ol.format.WKT();
            var selFeatureWkt = format.writeGeometry(e.feature.getGeometry(), {
                dataProjection: 'EPSG:4326',
                featureProjection: 'EPSG:3857'
            });
            wktCoordinate = selFeatureWkt;
            point.setActive(true);
            polygon.setActive(false);

            featureID = featureID + 1;
            e.feature.setProperties({
                'id': featureID
            })

            vectorDistrict.getSource().getFeatures().forEach(function (obje) {
                var objeExtend=obje.getGeometry().getExtent();
                var sonuc=ol.extent.intersects(objeExtend,e.feature.getGeometry().getExtent());

                if (sonuc) {
                    selectedObj = obje.get('DistrictCode');
                    showPop = true;
                }
            });
            vector.getSource().getFeatures().forEach(function (obje) {
                var objeExtend=obje.getGeometry().getExtent();
                var sonuc=ol.extent.intersects(objeExtend,e.feature.getGeometry().getExtent());
                    
                if (sonuc) {
                    selectedObj = obje.get('DistrictCode');
                    showPop = true;
                }
            });
        });

        polygon.on('drawend', function (e) {
            var format = new ol.format.WKT();
            var selFeatureWkt = format.writeGeometry(e.feature.getGeometry(), {
                dataProjection: 'EPSG:4326',
                featureProjection: 'EPSG:3857'
            });

            lastClick = true;
            wktCoordinate = selFeatureWkt;
            point.setActive(false);
            polygon.setActive(true);
            districtCode += 1;

            lastfea = e.feature;
            e.feature.setProperties({
                'DistrictCode': districtCode
            })
        });
        
        searchButton.onclick = function () {
            jsPanel.create({
                theme:       'primary',
                headerTitle: 'Search Place',
                position:    'center-top 0 58',
                contentSize: '500 370',
                content:     "<iframe src='http://localhost:49781/Search.html' width='100%' height='100%'></iframe>",
                callback: function () {
                    this.content.style.padding = '20px';
                }
            });
        }
        </script>
    </body>
</html>