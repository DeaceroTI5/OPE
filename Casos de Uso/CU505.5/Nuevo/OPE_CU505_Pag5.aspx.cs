using System;
using System.Transactions;
using WTool.View;
using System.Web.UI;
using WTool.View.Controls;
using System.Data;
using Microsoft.Reporting.WebForms;
using System.IO;
using System.Collections.Specialized;
using System.Configuration;
using System.Web.Configuration;
using System.Collections.Generic;
using WTool.View.Controls.Export;
using System.Collections;
using WTool.View.Utils;
using WTool.Common.Security;
public partial class OPE_CU505_Pag5 : BasePage
{
 public  DataSet MiDataSet;
 public  bool    MiHuboDatos = false;
 protected override void OnLoad(EventArgs e)
 {
  base.OnLoad(e);
  if (!IsPostBack)
  {
   AsignarFocus("FechaInicial");
   ExecutePerformanceLog("OnLoad");
  // Evaluo Defaults
   AsignarValor("ClaTipoInventario",1 );
   AsignarValor("NumVersion",1 );
   AsignarValor("Version",1 );
   AsignarValor("ClaFamiliaAlambron","1" );
   AsignarValor("EsInvocada",0 );
   this.CargarParametrosPagina();
  bool Habilita = false;
  // Tipo 5.- Acciones en el frente.   Validacion :@@SAVEOFF, @@NEWOFF, @@PRINTOFF, @@CLICK_CargarConfiguraciones,@@FiltraGrid_GrdMarca, @@Click2_BtnEsVisible
   // Solo se van a ejecutar acciones en el frente);
    control_Click(CargarConfiguraciones, null );
    control_Click(BtnEsVisible, null );
   HabilitarBotonToolbar("btnSave", false);
   HabilitarBotonToolbar("btnNew", false);
   HabilitarBotonToolbar("btnPrint", false);
        }
 }
    public override void OnHelp()
    {
		base.OnHelp();
    }
    public override void OnSearch()
    {
  DataSet dsGrid;
 bool hubodatos = false;
  string msgBusqNoResultado = string.IsNullOrEmpty(GetCommonMessage("MsgBusqNoResultado")) ? "No se encontró información para los filtros especificados" : GetCommonMessage("MsgBusqNoResultado");
   EstFacturacion.Search();
  dsGrid = EstFacturacion.DataSource as DataSet;
  if (dsGrid != null)
  {
   if (dsGrid.Tables.Count > 0)
      {
    if (dsGrid.Tables[0].Rows.Count > 0) {
     hubodatos = true;
    }
   }
  }
  if (hubodatos == false) { MostrarAviso(msgBusqNoResultado); return; }
    }
    public override void OnSave()
    {
  using (TransactionScope scope = new TransactionScope())
  {
   scope.Complete();  // Grabacion Total
  }
  Buscar();
  string msg = string.IsNullOrEmpty(GetCommonMessage("MsgOperExito")) ? "La operación se llevó a cabo con éxito" : GetCommonMessage("MsgOperExito");
  MostrarAviso(msg);
    }
    public override void OnExport()
    {
  List<ScreenFilter> filters = new List<ScreenFilter>();
  filters.Add(new ScreenFilter(string.Empty, ClaTipoInventario));
  filters.Add(new ScreenFilter(string.Empty, NumVersion));
  filters.Add(new ScreenFilter("NumBox", Version));
  filters.Add(new ScreenFilter(string.Empty, ClaFamiliaAlambron));
  filters.Add(new ScreenFilter(string.Empty, EsInvocada));
  filters.Add(new ScreenFilter(string.Empty, EsVisible));
  filters.Add(new ScreenFilter(lblFechaInicial.Text, FechaInicial));
  filters.Add(new ScreenFilter(lblFechaFinal.Text, FechaFinal));
  filters.Add(new ScreenFilter(string.Empty, ClaFamilia));
  filters.Add(new ScreenFilter(string.Empty, ClaArticulo));
  filters.Add(new ScreenFilter(string.Empty, ClaCliente));
  filters.Add(new ScreenFilter(string.Empty, ClaGpoCosteo));
  filters.Add(new ScreenFilter(string.Empty, ClaArtAlambron));
  filters.Add(new ScreenFilter(string.Empty, ClaAgrupador));
  filters.Add(new ScreenFilter(string.Empty, ClaTipoMercado));
  filters.Add(new ScreenFilter(string.Empty, ClaMarca));
  ExcelExporter.Export(filters);
    }
    public void grid_InitializeRow(object sender, WebGridInitializeRowArgs e)
   {
  WebGrid gridE = (WebGrid)sender;
  if (!e.IsReinitialize)
  {
   WebGrid  grid = (WebGrid)sender;
     }
    }
    public void grid_InitializeRowJer(object sender, WebHGridInitializeRowArgs e)
   {
  WebHierarchicalGrid gridE = (WebHierarchicalGrid)sender;
  if (!e.IsReinitialize)
  {
   WebHierarchicalGrid  grid = (WebHierarchicalGrid)sender;
     }
    }
 protected void control_ValueChanged(object obj, EventArgs Args)
 {
  bool Habilita = false;
  IWControl control = (IWControl)obj;
 }
 protected void grid_ValueChange(object sender, WebGridValueChangeArgs e)
 {
     WebGrid  grid = (WebGrid)sender;
  bool Habilita = false;
  if (grid.ID == "EstFacturacion" && e.Column.Key == "KilosSurtidos"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@Total
   // Solo se van a ejecutar acciones en el frente);
   EstFacturacion.Update();
   return;
  }
 }
 protected void grid_LinkButtonClick(object sender, WebGridLinkButtonArgs e)
 {
     WebGrid  grid = (WebGrid)sender;
  bool Habilita = false;
  if (grid.ID == "EstFacturacion" && e.Column.Key == "KilosSurtidos"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@Total
   // Solo se van a ejecutar acciones en el frente);
   EstFacturacion.Update();
   return;
  }
 }
 protected void grid_LinkButtonClickJer(object sender, WebHGridLinkButtonArgs e)
 {
     WebHierarchicalGrid grid = (WebHierarchicalGrid)sender;
  bool Habilita = false;
 }
 protected void control_Click(object obj, EventArgs Args)
 {
  bool Habilita = false;
  IWControl control = (IWControl)obj;
  if (control.ID == "CargarConfiguraciones"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@PROCR
   // Ejecuto el proceso del back);
        DataSet ds10;
  ds10 = EjecutaSpSel("OPESch.OPE_CU505_Pag5_Boton_CargarConfiguraciones_Proc");
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds10.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds10.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds10.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds10.Tables[0].Columns)
    { IWControl control10 = ObtenerControl(c.ColumnName);
     if (control10 != null)    { control10.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
   return;
  }
  if (control.ID == "BtnEsVisible"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@SInQueacer
   // Solo se van a ejecutar acciones en el frente);
  if ( (  WConvert.ToDecimal(ObtenerValor(EsVisible.ID)) == WConvert.ToDecimal(1) ) )
  {
   // @@VISIBLE_Mostrar
   // Solo se van a ejecutar acciones en el frente);
  Habilita =  ( 1 == 1);
  EstFacturacion.Columns["ShipID"].Visible = Habilita;
  EstFacturacion.Update();
  }
  else
  {
   // @@VISIBLE__Mostrar
   // Solo se van a ejecutar acciones en el frente);
  Habilita =  ( 1 == 1);
  EstFacturacion.Columns["ShipID"].Visible = !Habilita;
  EstFacturacion.Update();
   }
   return;
  }
 }
}
