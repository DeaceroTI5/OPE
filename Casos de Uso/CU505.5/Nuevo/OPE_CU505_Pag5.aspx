
<%@ Page Title="" Language="C#" Debug = "false" MasterPageFile="~/Common/MasterPage/Site.Master" AutoEventWireup="true" CodeFile="OPE_CU505_Pag5.aspx.cs" Inherits="OPE_CU505_Pag5" %>
<%@ Register Assembly="WTool" Namespace="WTool.View.Controls" TagPrefix="cc1" %> 
<asp:Content ID="Content1" ContentPlaceHolderID="ctn" runat="server" >
<div id="body">	
 <div id="body_content" class="container_24 pTB20" style="position:relative;">
<!-- 
 Esquema : OPESch 
 Modulo : 
 Caso de Uso : 505 
 Version : #Version# 
Usuario : GPODEACERO\hvalle 
 Titulo : Estadística de Facturación 
 Fecha : 220817 
 Release : 1 
 --> 

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="uCargarConfiguraciones" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="CargarConfiguraciones" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="false" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="uBtnEsVisible" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="BtnEsVisible" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="false" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 1005.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uClaTipoInventario" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="ClaTipoInventario" IsIgnored="true" runat="server" width="30.000px" Type="Decimal" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uNumVersion" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="NumVersion" IsIgnored="true" runat="server" width="30.000px" Type="Decimal" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uVersion" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="Version" IsIgnored="true" runat="server" width="30.000px" Type="Decimal" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 1045.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uClaFamiliaAlambron" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="ClaFamiliaAlambron" IsIgnored="true" runat="server" width="30.000px" Visible="false" CssClass="" Enabled="false" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uEsInvocada" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="EsInvocada" IsIgnored="true" runat="server" width="30.000px" Type="Decimal" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM ">
<asp:UpdatePanel ID="uEsVisible" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebNumericText ID="EsVisible" IsIgnored="true" runat="server" width="30.000px" Type="Clave" AllowNegative="false" Decimales="0" CssClass="" Visible="false" Enabled="false" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 4.000px; display: inline; float: left; height: 37.000px; width: 228.000px;" class="dM ">
<asp:UpdatePanel ID="ulblFechas" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblFechas" runat="server" width="228.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 70.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblFechaInicial" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblFechaInicial" runat="server" Text="Del*:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 33.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 70.000px; white-space:nowrap;" class="dM ">
<asp:UpdatePanel ID="uFechaInicial" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebDatePicker ID="FechaInicial" IsFilter="true" IsRequired="true" runat="server" width="70.000px" Visible="true" Enabled="true" > </cc1:WebDatePicker> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 125.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 70.000px;" class="dM ">
	<asp:UpdatePanel ID="ulblFechaFinal" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="lblFechaFinal" runat="server" Text="Al*:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 145.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 70.000px; white-space:nowrap;" class="dM ">
<asp:UpdatePanel ID="uFechaFinal" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebDatePicker ID="FechaFinal" IsFilter="true" IsRequired="true" runat="server" width="70.000px" Visible="true" Enabled="true" > </cc1:WebDatePicker> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 240.000px; top: 4.000px; display: inline; float: left; height: 37.000px; width: 220.000px;" class="dM ">
<asp:UpdatePanel ID="ulblFamilia" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblFamilia" runat="server" width="220.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 245.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 210.000px;" class="dM ">
<asp:UpdatePanel ID="uClaFamilia" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaFamilia" IsFilter="true" runat="server" width="210.000px" Visible="true" Enabled="true" Sp="OPESch.OPECatFamiliaCmb" ColumnValue="ClaFamilia" ColumnDescription="NomFamilia" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 468.000px; top: 4.000px; display: inline; float: left; height: 37.000px; width: 240.000px;" class="dM ">
<asp:UpdatePanel ID="ulblProducto" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblProducto" runat="server" width="240.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 473.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 230.000px;" class="dM ">
<asp:UpdatePanel ID="uClaArticulo" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaArticulo" IsFilter="true" runat="server" width="230.000px" Visible="true" Enabled="true" Sp="OPESch.OPEArtArticuloFamiliaCmb" ColumnValue="ClaArticulo" ColumnDescription="NomArticulo" ParentCmb="ClaFamilia" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 54.000px; display: inline; float: left; height: 37.000px; width: 228.000px;" class="dM ">
<asp:UpdatePanel ID="ulblCliente" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblCliente" runat="server" width="228.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 218.000px;" class="dM ">
<asp:UpdatePanel ID="uClaCliente" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaCliente" IsFilter="true" runat="server" width="218.000px" Visible="true" Enabled="true" Sp="OPESch.OPEVtaClienteCmb" ColumnValue="ClaCliente" ColumnDescription="NomCliente" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 240.000px; top: 54.000px; display: inline; float: left; height: 37.000px; width: 220.000px;" class="dM ">
<asp:UpdatePanel ID="ulblGpoCosteo" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblGpoCosteo" runat="server" width="220.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 245.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 210.000px;" class="dM ">
<asp:UpdatePanel ID="uClaGpoCosteo" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaGpoCosteo" IsFilter="true" runat="server" width="210.000px" Visible="true" Enabled="true" Sp="OPESch.OPEArtGpoCosteoCmb" ColumnValue="ClaGpoCosteo" ColumnDescription="NomGpoCosteo" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 468.000px; top: 54.000px; display: inline; float: left; height: 37.000px; width: 240.000px;" class="dM ">
<asp:UpdatePanel ID="ulblAlambron" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblAlambron" runat="server" width="240.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 473.000px; top: 64.000px; display: inline; float: left; height: 17.000px; width: 230.000px;" class="dM ">
<asp:UpdatePanel ID="uClaArtAlambron" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaArtAlambron" IsFilter="true" runat="server" width="230.000px" Visible="true" Enabled="true" Sp="OPESch.OPEArtArticuloFamiliaCmb" ColumnValue="ClaArticulo" ColumnDescription="NomArticulo" ParentCmb="" MinChars="0" AdditionalParams="@pnClaFamilia=94" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 104.000px; display: inline; float: left; height: 37.000px; width: 228.000px;" class="dM ">
<asp:UpdatePanel ID="ulblAgrTipoProducto" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblAgrTipoProducto" runat="server" width="228.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 114.000px; display: inline; float: left; height: 17.000px; width: 218.000px;" class="dM ">
<asp:UpdatePanel ID="uClaAgrupador" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaAgrupador" IsFilter="true" runat="server" width="218.000px" Visible="true" Enabled="true" Sp="OPESch.OPECatTipoArticuloUbiCmb" ColumnValue="ClaTipoArticuloUbi" ColumnDescription="NomTipoArticuloUbi" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 240.000px; top: 104.000px; display: inline; float: left; height: 37.000px; width: 220.000px;" class="dM ">
<asp:UpdatePanel ID="ulblTipoMercado" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblTipoMercado" runat="server" width="220.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 245.000px; top: 114.000px; display: inline; float: left; height: 17.000px; width: 210.000px;" class="dM ">
<asp:UpdatePanel ID="uClaTipoMercado" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaTipoMercado" IsFilter="true" runat="server" width="210.000px" Visible="true" Enabled="true" Sp="OPESch.OPETipoMercadoEmbCmb" ColumnValue="ClaTipoMercadoEmb" ColumnDescription="NomTipoMercadoEmb" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 720.000px; top: 4.000px; display: inline; float: left; height: 162.000px; width: 240.000px;" class="dM ">
<asp:UpdatePanel ID="ulblMarca" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="lblMarca" runat="server" width="240.000px" Height="162.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 725.000px; top: 14.000px; display: inline; float: left; height: 142.000px; width: 230.000px;" class="dM ">
<asp:UpdatePanel ID="uClaMarca" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebCheckBoxList ID="ClaMarca" IsIgnored="true" runat="server" width="230.000px" Height="142.000px" Visible="true" Enabled="true" Sp="OPESch.OPEMarcaCmb" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 164.000px; display: inline; float: left; height: 242.000px; width: 960.000px;" class="dM "> 
 <asp:UpdatePanel ID="uEstFacturacion" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="EstFacturacion" runat="server" Height="242.000px" Width="960.000px" AllowInsert ="false" AllowEdit ="false" 
			 AllowDelete ="false" SpSearch = "OPESch.OPE_CU505_Pag5_Grid_EstFacturacion_Sel" SpIU = "" PageSize ="30" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" AllowSummary="true" 
			 AutoLeft="true" AutoHeight="true" AutoRight="true" AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridTextColumn				Width="35.000px"			 Key="ClaArticulo"		Text="ClaArticulo"																	EditMode="Never" Visible="false" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridDatePickerColumn		Width="75.000px"			 Align="Center" Key="FechaViaje"		Text="Fecha Viaje"																	EditMode="Never" Visible="true" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="ClaveArticulo"		Text="Clave"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="195.000px"			 Key="NomArticulo"		Text="Producto"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="ClaPedido"		Text="Pedido"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="195.000px"			 Key="NombreCliente"		Text="Cliente"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridDatePickerColumn		Width="75.000px"			 Align="Center" Key="FechaPromesaOrigen"		Text="Fecha Promesa"																	EditMode="Never" Visible="true" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Key="KilosSurtidos"		Text="Kgs. Surtido"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" HasSummary="true" SummaryType="Sum" NeedsValueChange="true" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Key="UnidadesSurtidas"		Text="Unidades Surtidas"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Key="ImporteFlete"		Text="Inporte Flete X Producto"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="35.000px"			 Align="Center" Key="ClaMoneda"		Text="Clave Moneda"	Type="Decimal"												EditMode="Never" Visible="false" Decimales = "2" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Left" Key="NombreCortoMoneda"		Text="Moneda"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="IdPlanCarga"		Text="Número Plan"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="IdViaje"		Text="Viaje"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="IdNumTabular"		Text="Tabular"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="IdFactura"		Text="Factura"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Align="Center" Key="ClaConsignado"		Text="Clave Consignado"	Type="Clave"												EditMode="Never" Visible="true" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="195.000px"			 Key="NombreConsignado"		Text="Nombre Consignado"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="75.000px"			 Align="Center" Key="IdOpm"		Text="OPM"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="155.000px"			 Key="NomTipoMercado"		Text="Tipo Mercado"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="235.000px"			 Key="NomTransportista"		Text="Transportista"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridNumericColumn			Width="75.000px"			 Key="PesoTeoricoKgs"		Text="Peso Teórico Kgs"	Type="Decimal"												EditMode="Never" Visible="true" Decimales = "4" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="235.000px"			 Key="ShipID"		Text="Ship ID"																	EditMode="Never" Visible="true" MaxLenght = "200"			 	NeedsValueChange="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
</div></div>
</asp:Content>
