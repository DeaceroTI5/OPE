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
public partial class OPE_CU550_Pag30 : BasePage
{
 public  DataSet MiDataSet;
 public  bool    MiHuboDatos = false;
 protected override void OnLoad(EventArgs e)
 {
  base.OnLoad(e);
  if (!IsPostBack)
  {
   AsignarFocus("IdPlanCargaFiltro");
   ExecutePerformanceLog("OnLoad");
  // Evaluo Defaults
   AsignarValor("FechaInicio",new DateTime( System.DateTime.Today.Year , System.DateTime.Today.Month , System.DateTime.Today.Day ) );
   AsignarValor("FechaFin",new DateTime( System.DateTime.Today.Year , System.DateTime.Today.Month , System.DateTime.Today.Day ) );
   this.CargarParametrosPagina();
  bool Habilita = false;
  // Tipo 5.- Acciones en el frente.   Validacion :@@SEARCHOFF,@@ancho_30, @@SAVEOFF, @@EDIT__1;2
   // Solo se van a ejecutar acciones en el frente);
  SetPageWidth(1200 );
  Habilita =  ( 1 == 1);
   HacerEditable(AsociarShipID.ID,!Habilita);
   HacerEditable(AgregarDocumento.ID,!Habilita);
   HabilitarBotonToolbar("btnSearch", false);
   HabilitarBotonToolbar("btnSave", false);
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
   PlanCargaEnc.Search();
  dsGrid = PlanCargaEnc.DataSource as DataSet;
  if (dsGrid != null)
  {
   if (dsGrid.Tables.Count > 0)
      {
    if (dsGrid.Tables[0].Rows.Count > 0) {
     hubodatos = true;
    }
   }
	dsGrid = PlanCargaEnc.DataSource as DataSet;
	if (dsGrid.Tables[0].Rows.Count > 0)
    {
		PlanCargaEnc.SetSelectedRow(0);
    }
  }
   ShippingTicketInfo.Search();
  dsGrid = ShippingTicketInfo.DataSource as DataSet;
  if (dsGrid != null)
  {
   if (dsGrid.Tables.Count > 0)
      {
    if (dsGrid.Tables[0].Rows.Count > 0) {
     hubodatos = true;
    }
   }
	dsGrid = ShippingTicketInfo.DataSource as DataSet;
	if (dsGrid.Tables[0].Rows.Count > 0)
    {
		ShippingTicketInfo.SetSelectedRow(0);
    }
  }
   InfoDocumento.Search();
  dsGrid = InfoDocumento.DataSource as DataSet;
  if (dsGrid != null)
  {
   if (dsGrid.Tables.Count > 0)
      {
    if (dsGrid.Tables[0].Rows.Count > 0) {
     hubodatos = true;
    }
   }
	dsGrid = InfoDocumento.DataSource as DataSet;
	if (dsGrid.Tables[0].Rows.Count > 0)
    {
		InfoDocumento.SetSelectedRow(0);
    }
  }
   PlanillaDet.Search();
  dsGrid = PlanillaDet.DataSource as DataSet;
  if (dsGrid != null)
  {
   if (dsGrid.Tables.Count > 0)
      {
    if (dsGrid.Tables[0].Rows.Count > 0) {
     hubodatos = true;
    }
   }
  }
   GridPlanCargaEnc.Search();
  dsGrid = GridPlanCargaEnc.DataSource as DataSet;
  if (dsGrid != null)
  {
   if (dsGrid.Tables.Count > 0)
      {
    if (dsGrid.Tables[0].Rows.Count > 0) {
     hubodatos = true;
    }
   }
  }
   GridPlanCargaDet.Search();
  dsGrid = GridPlanCargaDet.DataSource as DataSet;
  if (dsGrid != null)
  {
   if (dsGrid.Tables.Count > 0)
      {
    if (dsGrid.Tables[0].Rows.Count > 0) {
     hubodatos = true;
    }
   }
  }
   GridColada.Search();
  dsGrid = GridColada.DataSource as DataSet;
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
        GridPlanCargaEnc.Save();
        GridPlanCargaDet.Save();
        GridColada.Save();
   scope.Complete();  // Grabacion Total
  }
  Buscar();
  string msg = string.IsNullOrEmpty(GetCommonMessage("MsgOperExito")) ? "La operación se llevó a cabo con éxito" : GetCommonMessage("MsgOperExito");
  MostrarAviso(msg);
    }
    public override void OnExport()
    {
  List<ScreenFilter> filters = new List<ScreenFilter>();
  filters.Add(new ScreenFilter(string.Empty, IdViajeAux));
  filters.Add(new ScreenFilter(string.Empty, IdPlanCargaAux));
  filters.Add(new ScreenFilter(string.Empty, ShipIDAux));
  filters.Add(new ScreenFilter(string.Empty, PlacasAux));
  filters.Add(new ScreenFilter(string.Empty, IdDocumentoAux));
  filters.Add(new ScreenFilter(string.Empty, ClaTipoDocumentoAux));
  filters.Add(new ScreenFilter(string.Empty, NumDocumentoAux));
  filters.Add(new ScreenFilter(string.Empty, IdFabricacionAux));
  filters.Add(new ScreenFilter(string.Empty, EsNuevoDoc));
  filters.Add(new ScreenFilter(string.Empty, EsGenerarNuevo));
  filters.Add(new ScreenFilter(string.Empty, EsReemplazar));
  filters.Add(new ScreenFilter(lblPlanCarga.Text, IdPlanCargaFiltro));
  filters.Add(new ScreenFilter(lblViajeFiltro.Text, IdViajeFiltro));
  filters.Add(new ScreenFilter(lblCliente.Text, ClaCliente));
  filters.Add(new ScreenFilter(lblFechaInicio.Text, FechaInicio));
  filters.Add(new ScreenFilter(lblFechaFin.Text, FechaFin));
  filters.Add(new ScreenFilter(lblPlacas.Text, PlacasMod));
  filters.Add(new ScreenFilter(lblViaje.Text, IdViajeMod));
  filters.Add(new ScreenFilter(string.Empty, ExisteArchivo));
  filters.Add(new ScreenFilter("Fabricación:", ClaFabricacionMod));
  filters.Add(new ScreenFilter("Tipo Documento:", ClaTipoDocumentoMod));
  filters.Add(new ScreenFilter("Num. Documento", NumDocumentoMod));
  filters.Add(new ScreenFilter(string.Empty, IdDocumentoMod));
  filters.Add(new ScreenFilter(lblArchivoDoc.Text, Documento));
  filters.Add(new ScreenFilter(lblPlacas2.Text, PlacasMod2));
  filters.Add(new ScreenFilter(lblViaje2.Text, IdViajeMod2));
  filters.Add(new ScreenFilter(lblShippingTicket.Text, ClaShipID));
  filters.Add(new ScreenFilter(lblPlanCarga3.Text, IdPlanCargaMod3));
  filters.Add(new ScreenFilter(lblViaje3.Text, IdViajeMod3));
  filters.Add(new ScreenFilter("Viaje:", IdViajeMod4));
  filters.Add(new ScreenFilter("Ship Id", ShipIdMod4));
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
  if (grid.ID == "ShippingTicketInfo" && e.Column.Key == "btnEliminar"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :@@imagen_Delete16.png,ShipIDAux=@ShipId, @@MODAL_DesasociaShipId
   AsignarValorAut("ShipIDAux", e.Row["ShipId"] );
   MostrarModal("DesasociaShipId");
   ShippingTicketInfo.Update();
   return;
  }
  if (grid.ID == "InfoDocumento" && e.Column.Key == "btnEditarArchivo"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :EsNuevoDoc= 0, IdViajeMod=IdViajeAux, PlacasMod=PlacasAux, ClaFabricacionMod= @IdFabricacion, IdDocumentoMod = @IdDocumento , ClaTipoDocumentoMod = @ClaTipoDocumento, NumDocumentoMod =@NumDocumento, @@FILTRAMODAL_ModalDoc,@@MODAL_ModalDoc, @@EDIT__EditDoc, @@VISIBLE__ReemplazarDoc, @@VISIBLE__NuevoDoc, @@VISIBLE_AceptarDoc
   AsignarValor("EsNuevoDoc", 0);
   AsignarValorAut("IdViajeMod", ObtenerValor("IdViajeAux") );
   AsignarValorAut("PlacasMod", ObtenerValor("PlacasAux") );
   AsignarValorAut("ClaFabricacionMod", e.Row["IdFabricacion"] );
   AsignarValorAut("IdDocumentoMod", e.Row["IdDocumento"] );
   AsignarValorAut("ClaTipoDocumentoMod", e.Row["ClaTipoDocumento"] );
   AsignarValorAut("NumDocumentoMod", e.Row["NumDocumento"] );
   MostrarModal("ModalDoc");
   AsignarFocus("ClaTipoDocumentoMod");
        DataSet ds4;
   ds4 = EjecutaSpSel("OPESch.OPE_CU550_Pag30ModalDoc_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds4.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds4.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds4.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds4.Tables[0].Columns)
    { IWControl control4 = ObtenerControl(c.ColumnName);
     if (control4 != null)    { control4.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
  Habilita =  ( 1 == 1);
   HacerEditable(ClaFabricacionMod.ID,!Habilita);
   HacerEditable(ClaTipoDocumentoMod.ID,!Habilita);
   HacerEditable(NumDocumentoMod.ID,!Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnReemplazar.ID,!Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnNuevo.ID,!Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnAceptar.ID,Habilita);
   InfoDocumento.Update();
   return;
  }
  if (grid.ID == "InfoDocumento" && e.Column.Key == "btnAbrirArchivo"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@DESCARGA
   // Solo se van a ejecutar acciones en el frente);
   this.DescargarArchivo("OPESch.OPE_CU550_Pag30_LnkBoton_btnAbrirArchivo_Descarga", grid, e.Row );
   InfoDocumento.Update();
   return;
  }
  if (grid.ID == "GridPlanCargaEnc" && e.Column.Key == "ColPesoEmbarcado"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@TOTAL_SUM_ColPesoEmbarcado
   // Solo se van a ejecutar acciones en el frente);
   GridPlanCargaEnc.Update();
   return;
  }
  if (grid.ID == "GridPlanCargaDet" && e.Column.Key == "ColPesoEmbarcadoDet"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@TOTAL_SUM_ColPesoEmbarcadoDet
   // Solo se van a ejecutar acciones en el frente);
   GridPlanCargaDet.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaProveedorMP"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaProveedorMP_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaFabricacion"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaFabricacion_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaFabricacionDet"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaFabricacionDet_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "CantEmbarcada"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_CantEmbarcada_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaHorno"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaHorno_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaMolino"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaMolino_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
 }
 protected void grid_SelectedRowChange(object sender, WebGridSelectedRowChangeArgs e)
 {
     WebGrid  grid = (WebGrid)sender;
  bool Habilita = false;
  if (grid.ID == "PlanCargaEnc" || grid.ID == "PlanCargaEnc_Congela" ) {
   this.Session["PlanCargaEnc.Row"] =  e.GridRow.DataItemIndex+1;
  // Tipo 5.- Acciones en el frente.   Validacion :IdViajeAux=@IdViaje, IdPlanCargaAux=@IdPlanCarga, PlacasAux=@Placas,ShipIDAux=@ShipID,@@FILTRAGRID_ShippingTicketInfo,@@FILTRAGRID_InfoDocumento,@@EDIT_1;2;3
   AsignarValorAut("IdViajeAux", e.Row["IdViaje"] );
   AsignarValorAut("IdPlanCargaAux", e.Row["IdPlanCarga"] );
   AsignarValorAut("PlacasAux", e.Row["Placas"] );
   AsignarValorAut("ShipIDAux", e.Row["ShipID"] );
   // Solo se van a ejecutar acciones en el frente);
   ShippingTicketInfo.Search();  //Del FiltraGrid ShippingTicketInfo
   InfoDocumento.Search();  //Del FiltraGrid InfoDocumento
   ShippingTicketInfo.SetSelectedRow(0);   //Del FiltraGrid ShippingTicketInfo
   InfoDocumento.SetSelectedRow(0);   //Del FiltraGrid InfoDocumento
  Habilita =  ( 1 == 1);
   HacerEditable(AsociarShipID.ID,Habilita);
   HacerEditable(AgregarDocumento.ID,Habilita);
   HacerEditable(AgregarComentario.ID,Habilita);
   return;
  }
  if (grid.ID == "ShippingTicketInfo" || grid.ID == "ShippingTicketInfo_Congela" ) {
   this.Session["ShippingTicketInfo.Row"] =  e.GridRow.DataItemIndex+1;
  // Tipo 5.- Acciones en el frente.   Validacion :ShipIDAux=@ShipId,  @@FILTRAGRID_PlanillaDet, @@EDIT_1;2
   AsignarValorAut("ShipIDAux", e.Row["ShipId"] );
   // Solo se van a ejecutar acciones en el frente);
   PlanillaDet.Search();  //Del FiltraGrid PlanillaDet
  Habilita =  ( 1 == 1);
   HacerEditable(AsociarShipID.ID,Habilita);
   HacerEditable(AgregarDocumento.ID,Habilita);
   return;
  }
  if (grid.ID == "InfoDocumento" || grid.ID == "InfoDocumento_Congela" ) {
   this.Session["InfoDocumento.Row"] =  e.GridRow.DataItemIndex+1;
  // Tipo 5.- Acciones en el frente.   Validacion :IdFabricacionAux = @IdFabricacion, ClaTipoDocumentoAux = @ClaTipoDocumento, NumDocumentoAux = NumDocumento, IdDocumentoAux = IdDocumento
   AsignarValorAut("IdFabricacionAux", e.Row["IdFabricacion"] );
   AsignarValorAut("ClaTipoDocumentoAux", e.Row["ClaTipoDocumento"] );
   AsignarValorAut("NumDocumentoAux", e.Row["NumDocumento"] );
   AsignarValorAut("IdDocumentoAux", e.Row["IdDocumento"] );
   // Solo se van a ejecutar acciones en el frente);
   return;
  }
  if (grid.ID == "GridPlanCargaEnc" || grid.ID == "GridPlanCargaEnc_Congela" ) {
   this.Session["GridPlanCargaEnc.Row"] =  e.GridRow.DataItemIndex+1;
  // Tipo 5.- Acciones en el frente.   Validacion :@@CheckOFF,ViajeDetalle=@ColViaje,PlanCargaDetalle=@ColPlanCarga,Fabricacion=@ColFabricacion,@@FiltraGrid_GridPlanCargaDet
   AsignarValorAut("ViajeDetalle", e.Row["ColViaje"] );
   AsignarValorAut("PlanCargaDetalle", e.Row["ColPlanCarga"] );
   AsignarValorAut("Fabricacion", e.Row["ColFabricacion"] );
   // Solo se van a ejecutar acciones en el frente);
   GridPlanCargaDet.Search();  //Del FiltraGrid GridPlanCargaDet
   return;
  }
 }
 protected void grid_LinkButtonClick(object sender, WebGridLinkButtonArgs e)
 {
     WebGrid  grid = (WebGrid)sender;
  bool Habilita = false;
  if (grid.ID == "ShippingTicketInfo" && e.Column.Key == "btnEliminar"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :@@imagen_Delete16.png,ShipIDAux=@ShipId, @@MODAL_DesasociaShipId
   AsignarValorAut("ShipIDAux", e.Row["ShipId"] );
   MostrarModal("DesasociaShipId");
   ShippingTicketInfo.Update();
   return;
  }
  if (grid.ID == "InfoDocumento" && e.Column.Key == "btnEditarArchivo"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :EsNuevoDoc= 0, IdViajeMod=IdViajeAux, PlacasMod=PlacasAux, ClaFabricacionMod= @IdFabricacion, IdDocumentoMod = @IdDocumento , ClaTipoDocumentoMod = @ClaTipoDocumento, NumDocumentoMod =@NumDocumento, @@FILTRAMODAL_ModalDoc,@@MODAL_ModalDoc, @@EDIT__EditDoc, @@VISIBLE__ReemplazarDoc, @@VISIBLE__NuevoDoc, @@VISIBLE_AceptarDoc
   AsignarValor("EsNuevoDoc", 0);
   AsignarValorAut("IdViajeMod", ObtenerValor("IdViajeAux") );
   AsignarValorAut("PlacasMod", ObtenerValor("PlacasAux") );
   AsignarValorAut("ClaFabricacionMod", e.Row["IdFabricacion"] );
   AsignarValorAut("IdDocumentoMod", e.Row["IdDocumento"] );
   AsignarValorAut("ClaTipoDocumentoMod", e.Row["ClaTipoDocumento"] );
   AsignarValorAut("NumDocumentoMod", e.Row["NumDocumento"] );
   MostrarModal("ModalDoc");
   AsignarFocus("ClaTipoDocumentoMod");
        DataSet ds4;
   ds4 = EjecutaSpSel("OPESch.OPE_CU550_Pag30ModalDoc_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds4.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds4.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds4.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds4.Tables[0].Columns)
    { IWControl control4 = ObtenerControl(c.ColumnName);
     if (control4 != null)    { control4.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
  Habilita =  ( 1 == 1);
   HacerEditable(ClaFabricacionMod.ID,!Habilita);
   HacerEditable(ClaTipoDocumentoMod.ID,!Habilita);
   HacerEditable(NumDocumentoMod.ID,!Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnReemplazar.ID,!Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnNuevo.ID,!Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnAceptar.ID,Habilita);
   InfoDocumento.Update();
   return;
  }
  if (grid.ID == "InfoDocumento" && e.Column.Key == "btnAbrirArchivo"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@DESCARGA
   // Solo se van a ejecutar acciones en el frente);
   this.DescargarArchivo("OPESch.OPE_CU550_Pag30_LnkBoton_btnAbrirArchivo_Descarga", grid, e.Row );
   InfoDocumento.Update();
   return;
  }
  if (grid.ID == "GridPlanCargaEnc" && e.Column.Key == "ColPesoEmbarcado"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@TOTAL_SUM_ColPesoEmbarcado
   // Solo se van a ejecutar acciones en el frente);
   GridPlanCargaEnc.Update();
   return;
  }
  if (grid.ID == "GridPlanCargaDet" && e.Column.Key == "ColPesoEmbarcadoDet"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@TOTAL_SUM_ColPesoEmbarcadoDet
   // Solo se van a ejecutar acciones en el frente);
   GridPlanCargaDet.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaProveedorMP"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaProveedorMP_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaFabricacion"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaFabricacion_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaFabricacionDet"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaFabricacionDet_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "CantEmbarcada"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_CantEmbarcada_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaHorno"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaHorno_Sel", e.Row, e.GridRow);
   GridColada.Update();
   return;
  }
  if (grid.ID == "GridColada" && e.Column.Key == "ClaMolino"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      GridColada.SearchPersist("OPESch.OPE_CU550_Pag30_Grid_GridColada_CambioValor_ClaMolino_Sel", e.Row, e.GridRow);
   GridColada.Update();
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
  if (control.ID == "Search2"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@IMAGEN_..\Toolbar\search.png,@@EDIT_1;2;3;4, IdViajeAux=NULL, PlacasAux=NULL, ShipIDAux=NULL, IdFabricacionAux= NULL,ClaTipoDocumentoAux = NULL, IdDocumentoAux = NULL, IdViajeAux=NULL, PlacasAux=NULL, ShipIDAux=NULL, @@FILTRA
   AsignarValor("IdViajeAux", null);
   AsignarValor("PlacasAux",  null );
   AsignarValor("ShipIDAux",  null );
   AsignarValor("IdFabricacionAux", null);
   AsignarValor("ClaTipoDocumentoAux", null);
   AsignarValor("IdDocumentoAux", null);
   AsignarValor("IdViajeAux", null);
   AsignarValor("PlacasAux",  null );
   AsignarValor("ShipIDAux",  null );
   // Solo se van a ejecutar acciones en el frente);
   PlanCargaEnc.Clear();
   ShippingTicketInfo.Clear();
   InfoDocumento.Clear();
   PlanillaDet.Clear();
   GridPlanCargaEnc.Clear();
   GridPlanCargaDet.Clear();
   GridColada.Clear();
   Buscar();
  Habilita =  ( 1 == 1);
   HacerEditable(AsociarShipID.ID,Habilita);
   HacerEditable(AgregarDocumento.ID,Habilita);
   HacerEditable(AgregarComentario.ID,Habilita);
   HacerEditable(AgregarColada.ID,Habilita);
   return;
  }
  if (control.ID == "AsociarShipID"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :@@imagen_Agregar24.png,  IdViajeMod2=IdViajeAux, PlacasMod2=PlacasAux, ClaShipID=NULL,@@MODAL_ModalShipTicket
   AsignarValorAut("IdViajeMod2", ObtenerValor("IdViajeAux") );
   AsignarValorAut("PlacasMod2", ObtenerValor("PlacasAux") );
   AsignarValor("ClaShipID", null);
   MostrarModal("ModalShipTicket");
   AsignarFocus("ClaShipID");
   return;
  }
  if (control.ID == "AgregarDocumento"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :@@imagen_attach24.png, EsNuevoDoc= 1, IdViajeMod=IdViajeAux, PlacasMod=PlacasAux , ClaFabricacionMod = NULL, ClaTipoDocumentoMod = NULL, NumDocumentoMod=NULL , IdDocumentoMod= NULL, @@FILTRAMODAL_ModalDoc,@@MODAL_ModalDoc, @@EDIT_EditDoc, @@VISIBLE_ReemplazarDoc, @@VISIBLE_NuevoDoc, @@VISIBLE__AceptarDoc
   AsignarValor("EsNuevoDoc", 1);
   AsignarValorAut("IdViajeMod", ObtenerValor("IdViajeAux") );
   AsignarValorAut("PlacasMod", ObtenerValor("PlacasAux") );
   AsignarValor("ClaFabricacionMod", null);
   AsignarValor("ClaTipoDocumentoMod", null);
   AsignarValor("NumDocumentoMod", null);
   AsignarValor("IdDocumentoMod", null);
   MostrarModal("ModalDoc");
   AsignarFocus("ClaTipoDocumentoMod");
        DataSet ds4;
   ds4 = EjecutaSpSel("OPESch.OPE_CU550_Pag30ModalDoc_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds4.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds4.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds4.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds4.Tables[0].Columns)
    { IWControl control4 = ObtenerControl(c.ColumnName);
     if (control4 != null)    { control4.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
  Habilita =  ( 1 == 1);
   HacerEditable(ClaFabricacionMod.ID,Habilita);
   HacerEditable(ClaTipoDocumentoMod.ID,Habilita);
   HacerEditable(NumDocumentoMod.ID,Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnReemplazar.ID,Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnNuevo.ID,Habilita);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnAceptar.ID,!Habilita);
   return;
  }
  if (control.ID == "AgregarComentario"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :@@imagen_RequisicionManual24.png,  IdViajeMod3=IdViajeAux, IdPlanCargaMod3=IdPlanCargaAux , @@FILTRAMODAL_ModalComentarios,@@MODAL_ModalComentarios
   AsignarValorAut("IdViajeMod3", ObtenerValor("IdViajeAux") );
   AsignarValorAut("IdPlanCargaMod3", ObtenerValor("IdPlanCargaAux") );
   MostrarModal("ModalComentarios");
        DataSet ds4;
   ds4 = EjecutaSpSel("OPESch.OPE_CU550_Pag30ModalComentarios_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds4.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds4.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds4.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds4.Tables[0].Columns)
    { IWControl control4 = ObtenerControl(c.ColumnName);
     if (control4 != null)    { control4.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
    GridPlanCargaEnc.Search();     // Del FiltraModal -> ModalComentarios       129
    GridPlanCargaDet.Search();     // Del FiltraModal -> ModalComentarios       129
   return;
  }
  if (control.ID == "AgregarColada"  ) {
  // Tipo 2.- Apertura de una Pantalla Modal.   Validacion :@@imagen_Fabricaciones.png,  IdViajeMod4=IdViajeAux, ShipIDMod4 = ShipIDAux , @@FILTRAMODAL_ModalColadas,@@MODAL_ModalColadas
   AsignarValorAut("IdViajeMod4", ObtenerValor("IdViajeAux") );
   AsignarValorAut("ShipIdMod4", ObtenerValor("ShipIDAux") );
   MostrarModal("ModalColadas");
        DataSet ds4;
   ds4 = EjecutaSpSel("OPESch.OPE_CU550_Pag30ModalColadas_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds4.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds4.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds4.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds4.Tables[0].Columns)
    { IWControl control4 = ObtenerControl(c.ColumnName);
     if (control4 != null)    { control4.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
    GridColada.Search();     // Del FiltraModal -> ModalColadas       171
   return;
  }
  if (control.ID == "ConfirmarDocumento"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@REQ_ClaTipoDocumentoMod_Documento_ClaFabricacionMod, @@PROCR,,@@SInQueacer
   // Ejecuto el proceso del back);
        DataSet ds10;
  ds10 = EjecutaSpSel("OPESch.OPE_CU550_Pag30_Boton_ConfirmarDocumento_Proc");
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
  if ( (  WConvert.ToDecimal(ObtenerValor(ExisteArchivo.ID)) > WConvert.ToDecimal(0) ) )
  {
   // @@CLICK_MostrarBtn1, @@MODAL_ConfirmarRegistro
   MostrarModal("ConfirmarRegistro");
    control_Click(MostrarBtn1, null );
  }
  else
  {
   // EsGenerarNuevo = 1, EsReemplazar = 0, @@CLICK_GuardaDoc
   AsignarValor("EsGenerarNuevo", 1);
   AsignarValor("EsReemplazar", 0);
   // Solo se van a ejecutar acciones en el frente);
    control_Click(GuardaDoc, null );
   }
   return;
  }
  if (control.ID == "GuardaDoc"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@REQ_ClaTipoDocumentoMod_Documento_ClaFabricacionMod, @@GRABAMODAL_ModalDoc, @@RETORNO, @@FILTRAGRID_InfoDocumento
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
  using (TransactionScope scope = new TransactionScope())
  {
   EjecutaSpIU("OPESch.OPE_CU550_Pag30ModalDoc_IU" );
   scope.Complete();
  }
        DataSet ds2;
   ds2 = EjecutaSpSel("OPESch.OPE_CU550_Pag30ModalDoc_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds2.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds2.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds2.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds2.Tables[0].Columns)
    { IWControl control2 = ObtenerControl(c.ColumnName);
     if (control2 != null)    { control2.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
   InfoDocumento.Search();  //Del FiltraGrid InfoDocumento
   InfoDocumento.SetSelectedRow(0);   //Del FiltraGrid InfoDocumento
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
  if (control.ID == "SalirDoc"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@imagen_Salir32.png, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
  if (control.ID == "MostrarBtn1"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :, @@CLICK_MostrarBtn2,@@SInQueacer
   // Solo se van a ejecutar acciones en el frente);
    control_Click(MostrarBtn2, null );
  if ( (  WConvert.ToDecimal(ObtenerValor(ExisteArchivo.ID)) == WConvert.ToDecimal(1) ) )
  {
   // @@VISIBLE_AceptarDoc
   // Solo se van a ejecutar acciones en el frente);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnAceptar.ID,Habilita);
  }
  else
  {
   // @@VISIBLE__AceptarDoc
   // Solo se van a ejecutar acciones en el frente);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnAceptar.ID,!Habilita);
   }
   return;
  }
  if (control.ID == "MostrarBtn2"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@SInQueacer
   // Solo se van a ejecutar acciones en el frente);
  if ( (  WConvert.ToDecimal(ObtenerValor(ExisteArchivo.ID)) == WConvert.ToDecimal(2) ) )
  {
   // @@VISIBLE_ReemplazarDoc
   // Solo se van a ejecutar acciones en el frente);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnReemplazar.ID,Habilita);
  }
  else
  {
   // @@VISIBLE__ReemplazarDoc
   // Solo se van a ejecutar acciones en el frente);
  Habilita =  ( 1 == 1);
   HacerVisible(BtnReemplazar.ID,!Habilita);
   }
   return;
  }
  if (control.ID == "GuardaDoc2"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@REQ_ClaShipID, @@GRABAMODAL_ModalShipTicket, @@RETORNO, @@FILTRA, @@EDIT__1;2, ShipIDAux=NULL, IdViajeAux=NULL,PlacasAux=NULL
   AsignarValor("ShipIDAux",  null );
   AsignarValor("IdViajeAux", null);
   AsignarValor("PlacasAux",  null );
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
  using (TransactionScope scope = new TransactionScope())
  {
   EjecutaSpIU("OPESch.OPE_CU550_Pag30ModalShipTicket_IU" );
   scope.Complete();
  }
        DataSet ds2;
   ds2 = EjecutaSpSel("OPESch.OPE_CU550_Pag30ModalShipTicket_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds2.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds2.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds2.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds2.Tables[0].Columns)
    { IWControl control2 = ObtenerControl(c.ColumnName);
     if (control2 != null)    { control2.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
   PlanCargaEnc.Clear();
   ShippingTicketInfo.Clear();
   InfoDocumento.Clear();
   PlanillaDet.Clear();
   GridPlanCargaEnc.Clear();
   GridPlanCargaDet.Clear();
   GridColada.Clear();
   Buscar();
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
  Habilita =  ( 1 == 1);
   HacerEditable(AsociarShipID.ID,!Habilita);
   HacerEditable(AgregarDocumento.ID,!Habilita);
   return;
  }
  if (control.ID == "SalirDoc2"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@imagen_Salir32.png, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
  if (control.ID == "Desasociar"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@GRABAMODAL_DesasociaShipId, @@RETORNO, @@FILTRAGRID_ShippingTicketInfo
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
  using (TransactionScope scope = new TransactionScope())
  {
   EjecutaSpIU("OPESch.OPE_CU550_Pag30DesasociaShipId_IU" );
   scope.Complete();
  }
        DataSet ds2;
   ds2 = EjecutaSpSel("OPESch.OPE_CU550_Pag30DesasociaShipId_Sel" );
   // -------------- Asigno Valores de lo que regereso el SP ---------------------------------------
   if (ds2.Tables[0].Rows.Count > 0)
   { foreach (DataColumn c in ds2.Tables[0].Columns) {  AsignarValorAut(c.ColumnName, ds2.Tables[0].Rows[0][c.ColumnName]); }
   }
   else
   {
    foreach (DataColumn c in ds2.Tables[0].Columns)
    { IWControl control2 = ObtenerControl(c.ColumnName);
     if (control2 != null)    { control2.Clear(); }
    }
   }
   // -------------------------------------------------------------------------------------------------
   ShippingTicketInfo.Search();  //Del FiltraGrid ShippingTicketInfo
   ShippingTicketInfo.SetSelectedRow(0);   //Del FiltraGrid ShippingTicketInfo
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
  if (control.ID == "SalirDesasociar"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@imagen_Salir32.png, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
  if (control.ID == "btnLimpiarMod"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@LimpiaModal_ModalComentarios
   // Solo se van a ejecutar acciones en el frente);
   IdPlanCargaMod3.Clear();
   IdViajeMod3.Clear();
   ViajeDetalle.Clear();
   PlanCargaDetalle.Clear();
   Fabricacion.Clear();
   return;
  }
  if (control.ID == "btnConfirmarComentarios"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@CLICK_btnGrabarComentarios,@@AVISO_La acción se efectuó correctamente.,@@CLICK2_btnLimpiarMod
   // Solo se van a ejecutar acciones en el frente);
    control_Click(btnGrabarComentarios, null );
    control_Click(btnLimpiarMod, null );
   MostrarAviso(GetMessage("MsgAviso1"));
   return;
  }
  if (control.ID == "btnGrabarComentarios"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@TOCAGRID_GridPlanCargaDet_INS,@@GRABAGRID_GridPlanCargaDet
   // Solo se van a ejecutar acciones en el frente);
   Hashtable hs1 = new Hashtable();
   GridPlanCargaDet.SetRowState(hs1, WebGridRowState.Added);
  using (TransactionScope scope = new TransactionScope())
  {
   GridPlanCargaDet.Save();
   scope.Complete();
  }
   GridPlanCargaDet.Search();
   return;
  }
  if (control.ID == "BtnConfirmarCom"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@CLICK2_btnConfirmarComentarios, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
    control_Click(btnConfirmarComentarios, null );
   return;
  }
  if (control.ID == "BtnCancelarCom"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@CLICK_btnLimpiarMod, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
    control_Click(btnLimpiarMod, null );
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
  if (control.ID == "BtnReemplazar"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :EsNuevoDoc = 1, EsGenerarNuevo=0, EsReemplazar= 1, @@CLICK_GuardaDoc
   AsignarValor("EsNuevoDoc", 1);
   AsignarValor("EsGenerarNuevo", 0);
   AsignarValor("EsReemplazar", 1);
   // Solo se van a ejecutar acciones en el frente);
    control_Click(GuardaDoc, null );
   return;
  }
  if (control.ID == "BtnNuevo"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :EsNuevoDoc = 1, EsGenerarNuevo=1, EsReemplazar= 0, @@CLICK_GuardaDoc
   AsignarValor("EsNuevoDoc", 1);
   AsignarValor("EsGenerarNuevo", 1);
   AsignarValor("EsReemplazar", 0);
   // Solo se van a ejecutar acciones en el frente);
    control_Click(GuardaDoc, null );
   return;
  }
  if (control.ID == "BtnAceptar"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :EsNuevoDoc = 0, EsGenerarNuevo=0, EsReemplazar= 1, @@CLICK_GuardaDoc
   AsignarValor("EsNuevoDoc", 0);
   AsignarValor("EsGenerarNuevo", 0);
   AsignarValor("EsReemplazar", 1);
   // Solo se van a ejecutar acciones en el frente);
    control_Click(GuardaDoc, null );
   return;
  }
  if (control.ID == "btnCancelar"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
  if (control.ID == "btnLimpiarMod4"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@LimpiaModal_ModalColadas
   // Solo se van a ejecutar acciones en el frente);
   IdViajeMod4.Clear();
   ShipIdMod4.Clear();
   return;
  }
  if (control.ID == "btnConfirmarColadas"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@CLICK_btnGrabarColadas,@@AVISO_La acción se efectuó correctamente.,@@CLICK2_btnLimpiarMod4
   // Solo se van a ejecutar acciones en el frente);
    control_Click(btnGrabarColadas, null );
    control_Click(btnLimpiarMod4, null );
   MostrarAviso(GetMessage("MsgAviso1"));
   return;
  }
  if (control.ID == "btnGrabarColadas"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :,@@GRABAGRID_GridColada
   // Solo se van a ejecutar acciones en el frente);
  using (TransactionScope scope = new TransactionScope())
  {
   GridColada.Save();
   scope.Complete();
  }
   GridColada.Search();
   return;
  }
  if (control.ID == "BtnGenerarCertificado"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@PROC, @@Aviso_Se generaron correctamente los Certificados, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   EjecutaSpProc("OPESch.OPE_CU550_Pag30_Boton_BtnGenerarCertificado_Proc");
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   MostrarAviso(GetMessage("MsgAviso3"));
   return;
  }
  if (control.ID == "BtnConfirmarColada"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@CLICK2_btnConfirmarColadas, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
    control_Click(btnConfirmarColadas, null );
   return;
  }
  if (control.ID == "BtnCancelarColada"  ) {
  // Tipo 4.- Cierre de una modal.   Validacion :@@CLICK_btnLimpiarMod, @@RETORNO
   // ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
    control_Click(btnLimpiarMod, null );
   // Ejecuto la accion de forma retardada (Cierre Modal)
   ScriptManager.RegisterStartupScript(this, GetType(), "", "$.fancybox.close();", true);
   return;
  }
 }
}
