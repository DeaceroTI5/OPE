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
public partial class OPE_CU550_Pag37 : BasePage
{
 public  DataSet MiDataSet;
 public  bool    MiHuboDatos = false;
 protected override void OnLoad(EventArgs e)
 {
  base.OnLoad(e);
  if (!IsPostBack)
  {
   AsignarFocus("NumFacturaFilial");
   ExecutePerformanceLog("OnLoad");
  // Evaluo Defaults
   this.CargarParametrosPagina();
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
   FacturasSumDirecto.Search();
  dsGrid = FacturasSumDirecto.DataSource as DataSet;
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
        FacturasSumDirecto.Save();
  bool Habilita = false;
  // Tipo 5.- Acciones en el frente.   Validacion :@@CLICK2_SAVE2
   // Solo se van a ejecutar acciones en el frente);
    control_Click(SAVE2, null );
   scope.Complete();  // Grabacion Total
  }
  Buscar();
  string msg = string.IsNullOrEmpty(GetCommonMessage("MsgOperExito")) ? "La operación se llevó a cabo con éxito" : GetCommonMessage("MsgOperExito");
  MostrarAviso(msg);
    }
    public override void OnExport()
    {
  List<ScreenFilter> filters = new List<ScreenFilter>();
  filters.Add(new ScreenFilter("Factura Filial", NumFacturaFilial));
  filters.Add(new ScreenFilter("Ubicación Origen:", ClaUbicacionOrigen));
  filters.Add(new ScreenFilter("Factura Origen:", NumFacturaOrigen));
  filters.Add(new ScreenFilter(VerBajas.Text, VerBajas));
  filters.Add(new ScreenFilter("FacturaFilial", FacturaFilial));
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
  if (control.ID == "VerBajas"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@FILTRAGRID_FacturasSumDirecto
   // Solo se van a ejecutar acciones en el frente);
   FacturasSumDirecto.Search();  //Del FiltraGrid FacturasSumDirecto
   return;
  }
 }
 protected void grid_ValueChange(object sender, WebGridValueChangeArgs e)
 {
     WebGrid  grid = (WebGrid)sender;
  bool Habilita = false;
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "NumFacturaFilial"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      FacturasSumDirecto.SearchPersist("OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaFilial_Sel", e.Row, e.GridRow);
   FacturasSumDirecto.Update();
   return;
  }
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "NumFacturaOrigen"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      FacturasSumDirecto.SearchPersist("OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel", e.Row, e.GridRow);
   FacturasSumDirecto.Update();
   return;
  }
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "Descarga"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@IMAGEN_attach24.png, @@DESCARGA
   // Solo se van a ejecutar acciones en el frente);
   this.DescargarArchivo("OPESch.OPE_CU550_Pag37_LnkBoton_Descarga_Descarga", grid, e.Row );
   FacturasSumDirecto.Update();
   return;
  }
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "EsRegenerar"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :FacturaFilial = @NumFacturaFilial, @@PROC, @@FILTRAGRID_FacturasSumDirecto, @@AVISO_La operación se llevó a cabo con éxito.
   AsignarValorAut("FacturaFilial", e.Row["NumFacturaFilial"] );
   // Ejecuto el proceso del back);
   EjecutaSpProc("OPESch.OPE_CU550_Pag37_Boton_EsRegenerar_Proc");
   FacturasSumDirecto.Search();  //Del FiltraGrid FacturasSumDirecto
   MostrarAviso(GetMessage("MsgAviso1"));
   FacturasSumDirecto.Update();
   return;
  }
 }
 protected void grid_SelectedRowChange(object sender, WebGridSelectedRowChangeArgs e)
 {
     WebGrid  grid = (WebGrid)sender;
  bool Habilita = false;
 }
 protected void grid_LinkButtonClick(object sender, WebGridLinkButtonArgs e)
 {
     WebGrid  grid = (WebGrid)sender;
  bool Habilita = false;
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "NumFacturaFilial"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      FacturasSumDirecto.SearchPersist("OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaFilial_Sel", e.Row, e.GridRow);
   FacturasSumDirecto.Update();
   return;
  }
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "NumFacturaOrigen"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@Action3,
   // Ejecuto el proceso del back);
      FacturasSumDirecto.SearchPersist("OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_CambioValor_NumFacturaOrigen_Sel", e.Row, e.GridRow);
   FacturasSumDirecto.Update();
   return;
  }
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "Descarga"  ) {
  // Tipo 5.- Acciones en el frente.   Validacion :@@IMAGEN_attach24.png, @@DESCARGA
   // Solo se van a ejecutar acciones en el frente);
   this.DescargarArchivo("OPESch.OPE_CU550_Pag37_LnkBoton_Descarga_Descarga", grid, e.Row );
   FacturasSumDirecto.Update();
   return;
  }
  if (grid.ID == "FacturasSumDirecto" && e.Column.Key == "EsRegenerar"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :FacturaFilial = @NumFacturaFilial, @@PROC, @@FILTRAGRID_FacturasSumDirecto, @@AVISO_La operación se llevó a cabo con éxito.
   AsignarValorAut("FacturaFilial", e.Row["NumFacturaFilial"] );
   // Ejecuto el proceso del back);
   EjecutaSpProc("OPESch.OPE_CU550_Pag37_Boton_EsRegenerar_Proc");
   FacturasSumDirecto.Search();  //Del FiltraGrid FacturasSumDirecto
   MostrarAviso(GetMessage("MsgAviso1"));
   FacturasSumDirecto.Update();
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
  if (control.ID == "SAVE2"  ) {
  // Tipo 6.- Ejecucion de un proceso en SQL.   Validacion :@@RPROC
   // Ejecuto el proceso del back);
   EjecutaSpProc("OPESch.OPE_CU550_Pag37_Boton_SAVE2_Proc");
   FacturasSumDirecto.Clear();
   Buscar();
   return;
  }
 }
}
