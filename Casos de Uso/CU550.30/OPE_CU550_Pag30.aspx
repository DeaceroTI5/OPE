
<%@ Page Title="" Language="C#" Debug = "false" MasterPageFile="~/Common/MasterPage/Site.Master" AutoEventWireup="true" CodeFile="OPE_CU550_Pag30.aspx.cs" Inherits="OPE_CU550_Pag30" %>
<%@ Register Assembly="WTool" Namespace="WTool.View.Controls" TagPrefix="cc1" %> 
<asp:Content ID="Content1" ContentPlaceHolderID="ctn" runat="server" > 
<script type="text/javascript"> 
 var controlesRequeridos_ConfirmarDocumento = ["<%= ClaTipoDocumentoMod.ClientID%>|1","<%= Documento.ClientID%>|1","<%= ClaFabricacionMod.ClientID%>|1"]; 
 var controlesRequeridos_GuardaDoc = ["<%= ClaTipoDocumentoMod.ClientID%>|1","<%= Documento.ClientID%>|1","<%= ClaFabricacionMod.ClientID%>|1"]; 
 var controlesRequeridos_GuardaDoc2 = ["<%= ClaShipID.ClientID%>|1"]; 
</script>
<div id="body">	
 <div id="body_content" class="container_24 pTB20" style="position:relative;">
<!-- 
 Esquema : OPESch 
 Modulo : 
 Caso de Uso : 550 
 Version : #Version# 
Usuario : GPODEACERO\hvalle 
 Titulo : Documentación Viajes Ingetek 
 Fecha : 220808 
 Release : 1 
 --> 

<div style="position:absolute; text-align:left; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="uSearch" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="Search" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="false" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:left; left: 975.000px; top: -36.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uSearch2" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebImageButton OnClick="control_Click" runat="server" ID="Search2" ImageUrl="/Common/Images/WebToolImages/..\Toolbar\search.png" Visible="true" Enabled="true" OnClientClick="" CssClass="" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 45.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uIdViajeAux" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdViajeAux" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 45.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uIdPlanCargaAux" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdPlanCargaAux" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 45.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uShipIDAux" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="ShipIDAux" IsIgnored="true" runat="server" width="30.000px" Visible="false" CssClass="" Enabled="false" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 45.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uPlacasAux" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="PlacasAux" IsIgnored="true" runat="server" width="30.000px" Visible="false" CssClass="" Enabled="false" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 39.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uIdDocumentoAux" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdDocumentoAux" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 39.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uClaTipoDocumentoAux" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="ClaTipoDocumentoAux" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 39.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uNumDocumentoAux" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="NumDocumentoAux" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 39.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uIdFabricacionAux" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdFabricacionAux" IsFilter="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 39.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uEsNuevoDoc" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="EsNuevoDoc" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 39.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uEsGenerarNuevo" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="EsGenerarNuevo" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 39.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uEsReemplazar" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="EsReemplazar" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 4.000px; display: inline; float: left; height: 37.000px; width: 1200.000px;" class="dM ">
<asp:UpdatePanel ID="uMarco1" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="Marco1" runat="server" width="1200.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 90.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblPlanCarga" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblPlanCarga" runat="server" Text="Plan Carga:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 77.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 70.000px;" class="dM ">
<asp:UpdatePanel ID="uIdPlanCargaFiltro" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdPlanCargaFiltro" IsIgnored="true" runat="server" width="70.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="true" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 185.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 50.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblViajeFiltro" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblViajeFiltro" runat="server" Text="Viaje:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 233.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 70.000px;" class="dM ">
<asp:UpdatePanel ID="uIdViajeFiltro" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdViajeFiltro" IsIgnored="true" runat="server" width="70.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="true" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 325.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 50.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblCliente" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblCliente" runat="server" Text="Cliente:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 385.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 150.000px;" class="dM ">
<asp:UpdatePanel ID="uClaCliente" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaCliente" IsIgnored="true" runat="server" width="150.000px" Visible="true" Enabled="true" Sp="OPESch.OPEEstConsClienteCmb" ColumnValue="ClaCliente" ColumnDescription="NomCliente" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 565.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 90.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblFechaInicio" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblFechaInicio" runat="server" Text="Fecha Inicio:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 645.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 90.000px; white-space:nowrap;" class="dM ">
<asp:UpdatePanel ID="uFechaInicio" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebDatePicker ID="FechaInicio" IsIgnored="true" IsRequired="true" runat="server" width="90.000px" Visible="true" Enabled="true" > </cc1:WebDatePicker> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 757.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 90.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblFechaFin" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblFechaFin" runat="server" Text="Fecha Fin:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 825.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 90.000px; white-space:nowrap;" class="dM ">
<asp:UpdatePanel ID="uFechaFin" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebDatePicker ID="FechaFin" IsIgnored="true" IsRequired="true" runat="server" width="90.000px" Visible="true" Enabled="true" > </cc1:WebDatePicker> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:left; left: 0.000px; top: 64.000px; display: inline; float: left; height: 167.000px; width: 1200.000px;" class="dM "> 
 <asp:UpdatePanel ID="uPlanCargaEnc" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="PlanCargaEnc" runat="server" Height="167.000px" Width="1200.000px" AllowInsert ="false" AllowEdit ="false" 
			 AllowDelete ="false" SpSearch = "OPESch.OPE_CU550_Pag30_Grid_PlanCargaEnc_Sel" SpIU = "" PageSize ="200" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" OnSelectedRowChange="grid_SelectedRowChange" 
			 WrapText="false" AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Left" Key="ShipID"		Text="ShipID"																	EditMode="Never" Visible="false" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Align="Left" Key="IdPlanCarga"		Text="Plan Carga"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Align="Left" Key="IdViaje"		Text="Viaje"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="95.000px"			 Align="Center" Key="IdBoleta"		Text="Boleta"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="175.000px"			 Align="Left" Key="NomTransportista"		Text="Transportista"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="175.000px"			 Align="Left" Key="NomTransporte"		Text="Transporte"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="Placas"		Text="Placa"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="115.000px"			 Align="Left" Key="NomChofer"		Text="Chofer"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="TonEmbarcadas"		Text="Ton. Embarcadas"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridDatePickerColumn		Width="75.000px"			 Align="Center" Key="FechaViaje"		Text="Fecha Viaje"																	EditMode="Never" Visible="true" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="KmRecorridos"		Text="Km Recorridos"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="115.000px"			 Align="Left" Key="DestinoFinal"		Text="Destino Final"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 1005.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uAsociarShipID" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebImageButton OnClick="control_Click" runat="server" ID="AsociarShipID" ImageUrl="/Common/Images/WebToolImages/Agregar24.png" Visible="true" Enabled="false" OnClientClick="" ToolTip = "Shipping Ticket" CssClass="" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 1045.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uAgregarDocumento" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebImageButton OnClick="control_Click" runat="server" ID="AgregarDocumento" ImageUrl="/Common/Images/WebToolImages/attach24.png" Visible="true" Enabled="false" OnClientClick="" ToolTip = "Documentos" CssClass="" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 1085.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uAgregarComentario" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebImageButton OnClick="control_Click" runat="server" ID="AgregarComentario" ImageUrl="/Common/Images/WebToolImages/RequisicionManual24.png" Visible="true" Enabled="false" OnClientClick="" ToolTip = "Comentarios" CssClass="" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 1125.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uAgregarColada" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebImageButton OnClick="control_Click" runat="server" ID="AgregarColada" ImageUrl="/Common/Images/WebToolImages/Fabricaciones.png" Visible="true" Enabled="false" OnClientClick="" ToolTip = "Certificados de Calidad" CssClass="" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:left; left: 0.000px; top: 239.000px; display: inline; float: left; height: 117.000px; width: 780.000px;" class="dM "> 
 <asp:UpdatePanel ID="uShippingTicketInfo" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="ShippingTicketInfo" runat="server" Height="117.000px" Width="780.000px" AllowInsert ="false" AllowEdit ="false" 
			 AllowDelete ="false" SpSearch = "OPESch.OPE_CU550_Pag30_Grid_ShippingTicketInfo_Sel" SpIU = "" PageSize ="200" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" OnSelectedRowChange="grid_SelectedRowChange" 
			 AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Left" Key="ShipId"		Text="Ship Id"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="99.000px"			 Align="Left" Key="WarehouseName"		Text="Warehouse Name"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridDatePickerColumn		Width="75.000px"			 Align="Left" Key="ShipDate"		Text="Ship Date"																	EditMode="Never" Visible="true" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="35.000px"			 Align="Center" Key="JobId"		Text="Job Id"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="83.000px"			 Align="Left" Key="JobName"		Text="Job Name"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="55.000px"			 Align="Center" Key="ShipStatusDescr"		Text="Status"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="51.000px"			 Align="Left" Key="CustomerId"		Text="Customer Id"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="103.000px"			 Align="Center" Key="CustomerName"		Text="Customer Name"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Left" Key="ShipWeight"		Text="Ship Weight"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="35.000px"			 Align="Center" Key="LoadId"		Text="Load Id"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridImageColumn			Width="35.000px"			 Align="Center" Key="btnEliminar"		Text="Baja"	UrlImage="/Common/Images/WebToolImages/Delete16.png"												EditMode="Always" Visible="true" NeedsValueChange="true" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:left; left: 792.000px; top: 239.000px; display: inline; float: left; height: 117.000px; width: 408.000px;" class="dM "> 
 <asp:UpdatePanel ID="uInfoDocumento" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="InfoDocumento" runat="server" Height="117.000px" Width="408.000px" AllowInsert ="false" AllowEdit ="false" 
			 AllowDelete ="false" SpSearch = "OPESch.OPE_CU550_Pag30_Grid_InfoDocumento_Sel" SpIU = "" PageSize ="200" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" OnSelectedRowChange="grid_SelectedRowChange" 
			 AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridLinkButtonColumn		Width="47.000px"			 Align="Center" Key="btnEditarArchivo"		Text="Editar"																	EditMode="Never" Visible="true" NeedsValueChange="true" Decimales="0" Type="Clave" />
<cc1:WebGridLinkButtonColumn		Width="47.000px"			 Align="Center" Key="btnAbrirArchivo"		Text="Ver"																	EditMode="Never" Visible="true" NeedsValueChange="true" Decimales="0" Type="Clave" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ClaTipoDocumento"		Text="Clave Tipo Documento"	Type="Clave"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Left" Key="TipoDocumento"		Text="Tipo Documento"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="155.000px"			 Align="Left" Key="NombreArchivo"		Text="Nombre"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="IdFabricacion"		Text="Fabricación"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="95.000px"			 Align="Center" Key="IdDocumento"		Text="Id Documento"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="NumDocumento"		Text="Num. Documento"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 364.000px; display: inline; float: left; height: 142.000px; width: 1200.000px;" class="dM "> 
 <asp:UpdatePanel ID="uPlanillaDet" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="PlanillaDet" runat="server" Height="142.000px" Width="1200.000px" AllowInsert ="false" AllowEdit ="false" 
			 AllowDelete ="false" SpSearch = "OPESch.OPE_CU550_Pag30_Grid_PlanillaDet_Sel" SpIU = "" PageSize ="200" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" 
			 AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridTextColumn				Width="95.000px"			 Key="Order"		Text="Order"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Key="ControlCode"		Text="Control Code"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Key="Status"		Text="Status"																	EditMode="Never" Visible="false" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Key="Product"		Text="Product"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="155.000px"			 Key="ProductDescr"		Text="Product Descr"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="35.000px"			 Key="Diameter"		Text="Diam"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="35.000px"			 Key="Grade"		Text="Grade"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="47.000px"			 Key="Texture"		Text="Texture"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="47.000px"			 Key="Material"		Text="Material"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="43.000px"			 Key="Coating"		Text="Coating"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="TotalItems"		Text="Total Items"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="TotalPieces"		Text="Total Pieces"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="TotalKgs"		Text="Total Kgs"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="StraightItems"		Text="Straight Items"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="StraightPieces"		Text="Straight Pieces"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="StraightKgs"		Text="Straight Kgs"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="BentItems"		Text="Bent Items"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="BentPieces"		Text="Bent Pieces"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="55.000px"			 Key="BentKgs"		Text="Bent Kgs"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="display: none; " >
	<div id="ModalDoc" CloseButton="true" style=" position:relative; height: 267.000px; width: 390.000px;" >

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 310.000px;" class="dM Titulo">
	<asp:UpdatePanel ID="ulblTitulo" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblTitulo" IsIgnored="true" runat="server" Text="Agregar documento" Visible="true" CssClass="Titulo" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblPlacas" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblPlacas" IsIgnored="true" runat="server" Text="Placas:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uPlacasMod" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="PlacasMod" IsIgnored="true" runat="server" width="110.000px" Visible="true" CssClass="" Enabled="false" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblViaje" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblViaje" IsIgnored="true" runat="server" Text="Viaje:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uIdViajeMod" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdViajeMod" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uExisteArchivo" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="ExisteArchivo" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 114.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle97" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele97" IsIgnored="true" runat="server" Text="Fabricación:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 114.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uClaFabricacionMod" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaFabricacionMod" IsIgnored="true" runat="server" width="110.000px" Visible="true" Enabled="false" Sp="OPESch.OPEFabricacionRel2Cmb" ColumnValue="ClaFabricacionRel2" ColumnDescription="NomFabricacionRel2" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 139.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle99" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele99" IsIgnored="true" runat="server" Text="Tipo Documento:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 139.000px; display: inline; float: left; height: 17.000px; width: 230.000px;" class="dM ">
<asp:UpdatePanel ID="uClaTipoDocumentoMod" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaTipoDocumentoMod" IsIgnored="true" runat="server" width="230.000px" Visible="true" Enabled="true" Sp="OPESch.OPEFormatoImpresionRel1Cmb" ColumnValue="ClaFormatoImpresion" ColumnDescription="NomFormatoImpresion" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 164.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle101" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele101" IsIgnored="true" runat="server" Text="Num. Documento" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 164.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uNumDocumentoMod" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="NumDocumentoMod" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="true" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 164.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uIdDocumentoMod" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdDocumentoMod" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="true" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 189.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblArchivoDoc" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblArchivoDoc" IsIgnored="true" runat="server" Text="Archivo:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 189.000px; display: inline; float: left; height: 17.000px; width: 230.000px;" class="dM ">
<asp:UpdatePanel ID="uDocumento" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFileUpload ID="Documento" IsIgnored="true" runat="server" width="230.000px" Visible="true" Enabled="true" NeedsValueChange="false" > </cc1:WebFileUpload> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 125.000px; top: 239.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uConfirmarDocumento" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="ConfirmarDocumento" IsIgnored="true" OnClick="control_Click" runat="server" Text="Aceptar" Height="22.000px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="return ( ValidaRequeridos(controlesRequeridos_ConfirmarDocumento) )" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 125.000px; top: 239.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uGuardaDoc" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="GuardaDoc" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="22.000px" width="70.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="return ( ValidaRequeridos(controlesRequeridos_GuardaDoc) )" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 205.000px; top: 239.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uSalirDoc" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="SalirDoc" IsIgnored="true" OnClick="control_Click" runat="server" Text="Cancelar" Height="22.000px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 125.000px; top: 239.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uMostrarBtn1" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="MostrarBtn1" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="22.000px" width="70.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 125.000px; top: 239.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uMostrarBtn2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="MostrarBtn2" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="22.000px" width="70.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
</div> </div>
<div style="display: none; " >
	<div id="ModalShipTicket" CloseButton="true" style=" position:relative; height: 242.000px; width: 350.000px;" >

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 250.000px;" class="dM Titulo">
	<asp:UpdatePanel ID="ulblTitulo2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblTitulo2" IsIgnored="true" runat="server" Text="Asociar Shipping Ticket" Visible="true" CssClass="Titulo" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblPlacas2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblPlacas2" IsIgnored="true" runat="server" Text="Placas:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uPlacasMod2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="PlacasMod2" IsIgnored="true" runat="server" width="110.000px" Visible="true" CssClass="" Enabled="false" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblViaje2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblViaje2" IsIgnored="true" runat="server" Text="Viaje:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uIdViajeMod2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdViajeMod2" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 139.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblShippingTicket" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblShippingTicket" IsIgnored="true" runat="server" Text="Shipping Ticket:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 139.000px; display: inline; float: left; height: 17.000px; width: 230.000px;" class="dM ">
<asp:UpdatePanel ID="uClaShipID" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaShipID" IsIgnored="true" runat="server" width="230.000px" Visible="true" Enabled="true" Sp="OPESch.OPEShipIDCmb" ColumnValue="ClaShipID" ColumnDescription="NomShipID" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 185.000px; top: 189.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uGuardaDoc2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="GuardaDoc2" IsIgnored="true" OnClick="control_Click" runat="server" Text="Aceptar" Height="22.000px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="return ( ValidaRequeridos(controlesRequeridos_GuardaDoc2) )" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 265.000px; top: 189.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uSalirDoc2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="SalirDoc2" IsIgnored="true" OnClick="control_Click" runat="server" Text="Salir" Height="22.000px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
</div> </div>
<div style="display: none; " >
	<div id="DesasociaShipId" CloseButton="true" style=" position:relative; height: 142.000px; width: 270.000px;" >

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 250.000px;" class="dM Titulo">
	<asp:UpdatePanel ID="ulblDesasociar" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblDesasociar" IsIgnored="true" runat="server" Text="Desasociar Shipping Ticket" Visible="true" CssClass="Titulo" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 250.000px;" class="dM FontBold">
	<asp:UpdatePanel ID="ulblDesasociar2" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblDesasociar2" IsIgnored="true" runat="server" Text="Se va a desasociar del viaje, desea continuar?" Visible="true" CssClass="FontBold" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 65.000px; top: 114.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uDesasociar" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="Desasociar" IsIgnored="true" OnClick="control_Click" runat="server" Text="Aceptar" Height="22.000px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 145.000px; top: 114.000px; display: inline; float: left; height: 22.000px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uSalirDesasociar" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="SalirDesasociar" IsIgnored="true" OnClick="control_Click" runat="server" Text="Salir" Height="22.000px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
</div> </div>
<div style="display: none; " >
	<div id="ModalComentarios" CloseButton="false" style=" position:relative; height: 542.000px; width: 830.000px;" >

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 230.000px;" class="dM Titulo">
	<asp:UpdatePanel ID="uEle130" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele130" IsIgnored="true" runat="server" Text="Comentarios de Remisión" Visible="true" CssClass="Titulo" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblPlanCarga3" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblPlanCarga3" IsIgnored="true" runat="server" Text="Plan de Carga:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uIdPlanCargaMod3" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdPlanCargaMod3" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblViaje3" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblViaje3" IsIgnored="true" runat="server" Text="Viaje:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 105.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uIdViajeMod3" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdViajeMod3" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 245.000px; top: 689.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="ubtnLimpiarMod" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="btnLimpiarMod" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 325.000px; top: 689.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="ubtnConfirmarComentarios" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="btnConfirmarComentarios" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 285.000px; top: 689.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="ubtnGrabarComentarios" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="btnGrabarComentarios" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 0.000px; top: 114.000px; display: inline; float: left; height: 167.000px; width: 800.000px;" class="dM "> 
 <asp:UpdatePanel ID="uGridPlanCargaEnc" IsIgnored="true" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="GridPlanCargaEnc" IsIgnored="true" runat="server" Height="167.000px" Width="800.000px" AllowInsert ="false" AllowEdit ="true" 
			 AllowDelete ="false" SpSearch = "OPESch.OPE_CU550_Pag30_Grid_GridPlanCargaEnc_Sel" SpIU = "OPESch.OPE_CU550_Pag30_Grid_GridPlanCargaEnc_IU" PageSize ="30" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" OnSelectedRowChange="grid_SelectedRowChange" AllowSummary="true" 
			 AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ColFabricacion"		Text="Fabricación"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ColBoleta"		Text="Boleta"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="175.000px"			 Align="Left" Key="ColTransportista"		Text="Transportista"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="175.000px"			 Align="Left" Key="ColTransporte"		Text="Transporte"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="ColPlaca"		Text="Placa"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="115.000px"			 Align="Center" Key="ColChofer"		Text="Chofer"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Right" Key="ColPesoEmbarcado"		Text="Peso Embarcado"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" HasSummary="true" SummaryType="Sum" NeedsValueChange="true" />
<cc1:WebGridNumericColumn			Width="35.000px"			 Align="Left" Key="ColViaje"		Text="Viaje"	Type="Clave"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="35.000px"			 Align="Left" Key="ColPlanCarga"		Text="Plan de Carga"	Type="Clave"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 85.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uViajeDetalle" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="ViajeDetalle" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 85.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uPlanCargaDetalle" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="PlanCargaDetalle" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 85.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uFabricacion" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="Fabricacion" IsIgnored="true" runat="server" width="110.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:left; left: 0.000px; top: 301.500px; display: inline; float: left; height: 167.000px; width: 800.000px;" class="dM "> 
 <asp:UpdatePanel ID="uGridPlanCargaDet" IsIgnored="true" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="GridPlanCargaDet" IsIgnored="true" runat="server" Height="167.000px" Width="800.000px" AllowInsert ="false" AllowEdit ="true" 
			 AllowDelete ="false" SpSearch = "OPESch.OPE_CU550_Pag30_Grid_GridPlanCargaDet_Sel" SpIU = "OPESch.OPE_CU550_Pag30_Grid_GridPlanCargaDet_IU" PageSize ="30" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" OnSelectedRowChange="grid_SelectedRowChange" AllowSummary="true" 
			 AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ColFabricacionDet"		Text="Fabricación"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ColNoRenglonDet"		Text="No. Renglón"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="235.000px"			 Align="Left" Key="ColProductoDet"		Text="Producto"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Right" Key="ColPesoEmbarcadoDet"		Text="Peso Embarcado"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" HasSummary="true" SummaryType="Sum" NeedsValueChange="true" />
<cc1:WebGridTextColumn				Width="315.000px"			 Align="Left" Key="ColComentarioDet"		Text="Comentario"																	EditMode="Always" Visible="true" MaxLenght = "800"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="35.000px"			 Align="Left" Key="ColViajeDet"		Text="Viaje"	Type="Clave"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="35.000px"			 Align="Left" Key="ColPlanCargaDet"		Text="Plan de Carga"	Type="Clave"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 625.000px; top: 501.500px; display: inline; float: left; height: 29.500px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnConfirmarCom" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnConfirmarCom" IsIgnored="true" OnClick="control_Click" runat="server" Text="Confirmar" Height="29.500px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 705.000px; top: 501.500px; display: inline; float: left; height: 29.500px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnCancelarCom" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnCancelarCom" IsIgnored="true" OnClick="control_Click" runat="server" Text="Cancelar" Height="29.500px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
</div> </div>
<div style="display: none; " >
	<div id="ConfirmarRegistro" CloseButton="true" style=" position:relative; height: 142.000px; width: 450.000px;" >

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 430.000px;" class="dM fontSmall">
	<asp:UpdatePanel ID="uEtConfirmaRegistro" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="EtConfirmaRegistro" IsIgnored="true" runat="server" Text="&nbsp" Visible="true" CssClass="fontSmall" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 45.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnReemplazar" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnReemplazar" IsIgnored="true" OnClick="control_Click" runat="server" Text="Reemplazar" Height="17.000px" width="110.000px" CssClass="action fontSmall" Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 165.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnNuevo" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnNuevo" IsIgnored="true" OnClick="control_Click" runat="server" Text="Generar Nuevo" Height="17.000px" width="110.000px" CssClass="action fontSmall" Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 165.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnAceptar" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnAceptar" IsIgnored="true" OnClick="control_Click" runat="server" Text="Aceptar" Height="17.000px" width="110.000px" CssClass="action fontSmall" Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 285.000px; top: 89.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM" >
<asp:UpdatePanel ID="ubtnCancelar" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="btnCancelar" IsIgnored="true" OnClick="control_Click" runat="server" Text="Cancelar" Height="17.000px" width="110.000px" CssClass="action fontSmall" Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
</div> </div>
<div style="display: none; " >
	<div id="ModalColadas" CloseButton="true" style=" position:relative; height: 517.000px; width: 1030.000px;" >

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 230.000px;" class="dM Titulo">
	<asp:UpdatePanel ID="uEle172" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele172" IsIgnored="true" runat="server" Text="Certificados de Calidad" Visible="true" CssClass="Titulo" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle173" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele173" IsIgnored="true" runat="server" Text="Viaje:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 45.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 90.000px;" class="dM ">
<asp:UpdatePanel ID="uIdViajeMod4" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="IdViajeMod4" IsIgnored="true" runat="server" width="90.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="true" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 165.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 50.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle175" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele175" IsIgnored="true" runat="server" Text="Ship Id" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 217.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 130.000px;" class="dM ">
<asp:UpdatePanel ID="uShipIdMod4" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="ShipIdMod4" IsIgnored="true" runat="server" width="130.000px" Visible="true" CssClass="" Enabled="false" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="ubtnLimpiarMod4" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="btnLimpiarMod4" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="ubtnConfirmarColadas" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="btnConfirmarColadas" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="ubtnGrabarColadas" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="btnGrabarColadas" IsIgnored="true" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; text-align:center; left: 0.000px; top: 114.000px; display: inline; float: left; height: 329.500px; width: 1000.000px;" class="dM "> 
 <asp:UpdatePanel ID="uGridColada" IsIgnored="true" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="GridColada" IsIgnored="true" runat="server" Height="329.500px" Width="1000.000px" AllowInsert ="true" AllowEdit ="true" 
			 AllowDelete ="true" SpSearch = "OPESch.OPE_CU550_Pag30_Grid_GridColada_Sel" SpIU = "OPESch.OPE_CU550_Pag30_Grid_GridColada_IU" PageSize ="200" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" OnSelectedRowChange="grid_SelectedRowChange" 
			 WrapText="false" AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" IsRequired="true" Key="IdColada"		Text="Colada"	Type="Clave"												EditMode="OnInsert" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" IsRequired="true" Key="Secuencia"		Text="Secuencia"	Type="Clave"												EditMode="OnInsert" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridComboBoxColumn			Width="215.000px"			 Align="Left" IsRequired="true" Key="ClaProveedorMP"		Text="Proveedor"	ColumnDescKey="NomProveedorMP"	Sp="OPESch.OPEOpcProveedorMPCmb" ParentCmbKey ="" EditMode="Always" Visible="true" MinChars="0"			 	NeedsValueChange="true" />
<cc1:WebGridComboBoxColumn			Width="95.000px"			 Align="Center" IsRequired="true" Key="ClaFabricacion"		Text="Fabricación"	ColumnDescKey="NomFabricacion"	Sp="OPESch.OPEFabricacionRel2Cmb" ParentCmbKey ="" EditMode="Always" Visible="true" MinChars="0"			 	NeedsValueChange="true" />
<cc1:WebGridComboBoxColumn			Width="55.000px"			 Align="Center" IsRequired="true" Key="ClaFabricacionDet"		Text="Renglón"	ColumnDescKey="NomFabricacionDet"	Sp="OPESch.OPEFabricacionDetRel2Cmb" ParentCmbKey ="ClaFabricacion" EditMode="Always" Visible="true" MinChars="0"			 	NeedsValueChange="true" />
<cc1:WebGridNumericColumn			Width="95.000px"			 Align="Right" IsRequired="true" Key="CantEmbarcada"		Text="Cantidad"	Type="Decimal"												EditMode="Always" Visible="true" Decimales = "0" NeedsValueChange="true" />
<cc1:WebGridNumericColumn			Width="95.000px"			 Align="Right" Key="PesoEmbarcado"		Text="Peso"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "4" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ClaArticulo"		Text="Articulo"	Type="Clave"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="235.000px"			 Align="Left" Key="Producto"		Text="Producto"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ClaHorno"		Text="Horno"	Type="Clave"												EditMode="Always" Visible="true" Decimales = "0" NeedsValueChange="true" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ClaMolino"		Text="Molino"	Type="Clave"												EditMode="Always" Visible="true" Decimales = "0" NeedsValueChange="true" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="IdFactura"		Text="Id Factura"	Type="Decimal"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="95.000px"			 Align="Center" Key="IdFacturaAlfanumerico"		Text="Factura"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 805.000px; top: 64.000px; display: inline; float: left; height: 29.500px; width: 130.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnGenerarCertificado" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnGenerarCertificado" IsIgnored="true" OnClick="control_Click" runat="server" Text="Generar Certificado" Height="29.500px" width="130.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 805.000px; top: 476.500px; display: inline; float: left; height: 29.500px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnConfirmarColada" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnConfirmarColada" IsIgnored="true" OnClick="control_Click" runat="server" Text="Aceptar" Height="29.500px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 885.000px; top: 476.500px; display: inline; float: left; height: 29.500px; width: 70.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnCancelarColada" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnCancelarColada" IsIgnored="true" OnClick="control_Click" runat="server" Text="Cancelar" Height="29.500px" width="70.000px" CssClass="action " Visible="true" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
</div> </div>
</div></div>
</asp:Content>
