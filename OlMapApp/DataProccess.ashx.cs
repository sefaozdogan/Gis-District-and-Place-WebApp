using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;

namespace OlMapApp
{
    /// <summary>
    /// Summary description for DataProccess
    /// </summary>
    public class DataProccess : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            SqlConnection conn = new SqlConnection("Data Source=DESKTOP-DL85PO5\\SQLEXPRESS;Initial Catalog=MapProjDB;Integrated Security=True");
            conn.Open();
            SqlCommand cmd = conn.CreateCommand();

            var function = context.Request.QueryString["f"];
            string districtName = "";
            string districtWkt = "";
            string responce = "";
            string districtCode = "";
            string placeNo = "";
            string placeCoord = "";
            switch (function)
            {
                case "AddDistrict":
                    districtName = context.Request.QueryString["DistrictName"];
                    districtWkt = context.Request.QueryString["DistrictWkt"];
                    districtCode = context.Request.QueryString["DistrictCode"];
                    cmd.CommandText = "insert into TblDistricts (DistrictName,DistrictWkt,DistrictCode)Values('" + districtName + "','" + districtWkt + "','" + districtCode + "')";
                    int sonuc = cmd.ExecuteNonQuery();
                    if (sonuc > 0)
                        responce = districtName + " is succesfully added";
                    else
                        responce += "Error";
                    cmd.Dispose();
                    conn.Close();
                    break;
                case "GetDistricts":
                    cmd.CommandText = "Select * from TblDistricts";
                    SqlDataAdapter adp = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Distincs");
                    adp.Fill(dt);
                    adp.Dispose();
                    cmd.Dispose();
                    conn.Close();
                    responce = Newtonsoft.Json.JsonConvert.SerializeObject(dt);
                    break;
                case "AddPlace":
                    districtCode = context.Request.QueryString["DistrictCode"];
                    placeNo = context.Request.QueryString["PlaceNo"];
                    placeCoord = context.Request.QueryString["PlaceCoord"];
                    cmd.CommandText = "insert into TblPlaces(PlaceNo,PlaceCoord,DistrictCode)Values('" + placeNo + "','" + placeCoord + "','" + districtCode + "')";
                    int sonucKapi = cmd.ExecuteNonQuery();
                    if (sonucKapi > 0)
                        responce = "Place no: " + placeNo + " is succesfully added in distinct code: " + districtCode;
                    else
                        responce += "Error";
                    cmd.Dispose();
                    conn.Close();
                    break;
                case "GetPlaces":
                    cmd.CommandText = "Select * from TblPlaces";
                    SqlDataAdapter adpKapi = new SqlDataAdapter(cmd);
                    DataTable dtKapi = new DataTable("Places");
                    adpKapi.Fill(dtKapi);
                    adpKapi.Dispose();
                    cmd.Dispose();
                    conn.Close();
                    responce = Newtonsoft.Json.JsonConvert.SerializeObject(dtKapi);
                    break;
                default:
                    break;
            }
            context.Response.ContentType = "text/html";
            context.Response.Write(responce);
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}