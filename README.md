## Synopsis

A map application that works on the web has been developed using Openlayers. The application contains various events that interact with the user on the map. The purpose of the application users can easily make districts and places operations on the map.

## Project Details

The main layer consists of the ‘Aerial Map With Labels’ and first opened on Turkey. The Bing Maps API is used for the main layer. The vector layer is also used for draw districts and point places. These two layers are shown on the map. 
Districts are converted into WKT (Well Know Text) format after being drawn in polygon type. Also places are converted into WKT format after being pointed in point type.

After a drawing or pointing operation is performed on the map, a popup is opened for the user to enter information. The information input by the users varies according to the drawing type. The condition for adding a place on the map is that it must be in a district coordinates.
The information is saved in the database after the user inputs the information of the pointed or drawn location through the popup. Every time the application is opened, the registered districts and places are retrieved from the database via Ajax. Users can receive information from the registered points when the Select tool is selected.

## Database
MsSql server is used in application's database. There are two tables, districts and places table in the database. Each table contains various information of location. The names and data types of the tables are shown below.

TblPlaces
Column Name		Data Type		Allow Nulls
---------------------------------------------------------------
DisctrictCode		varchar(50)		Yes
PlaceNo			varchar(50)		Yes
PlaceCoord		varchar(MAX)		Yes

TblDistricts
Column Name		Data Type		Allow Nulls
---------------------------------------------------------------
DistrictName		varchar(50)		Yes
DistrictCode		varchar(50)		Yes
DistrictWkt		varchar(MAX)		Yes