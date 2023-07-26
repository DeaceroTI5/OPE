
<%@ Page Title="" Language="C#" Debug = "false" MasterPageFile="~/Common/MasterPage/Site.Master" AutoEventWireup="true" CodeFile="OPE_CU550_Pag37.aspx.cs" Inherits="OPE_CU550_Pag37" %>
<%@ Register Assembly="WTool" Namespace="WTool.View.Controls" TagPrefix="cc1" %> 
<asp:Content ID="Content1" ContentPlaceHolderID="ctn" runat="server" >
<div id="body">	
 <div id="body_content" class="container_24 pTB20" style="position:relative;">
<!-- 
 Esquema : OPESch 
 Modulo : 
 Caso de Uso : 550 
 Version : #Version# 
Usuario : GPODEACERO\hvalle 
 Titulo : Certificados de Calidad de Suministro Directo 
 Fecha : 230623 
 Release : 1 
 --> 

<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="uLoad" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="Load" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 30.000px;" class="dM" >
<asp:UpdatePanel ID="uSAVE2" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebButton ID="SAVE2" OnClick="control_Click" runat="server" Text="" Height="17.000px" width="30.000px" CssClass="action " Visible="false" Enabled="true" OnClientClick="" LoadingTime="0"> 	</cc1:WebButton> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 4.000px; display: inline; float: left; height: 37.000px; width: 960.000px;" class="dM ">
<asp:UpdatePanel ID="uEle7" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebFrame ID="Ele7" runat="server" width="960.000px" Height="37.000px" CssClass=""	Visible="true" ></cc1:WebFrame> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 5.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle8" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele8" runat="server" Text="Factura Filial" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 85.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uNumFacturaFilial" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="NumFacturaFilial" IsFilter="true" runat="server" width="110.000px" Visible="true" CssClass="" Enabled="true" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 225.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle10" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele10" runat="server" Text="Ubicación Origen:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 337.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 190.000px;" class="dM ">
<asp:UpdatePanel ID="uClaUbicacionOrigen" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebComboBox ID="ClaUbicacionOrigen" IsFilter="true" runat="server" width="190.000px" Visible="true" Enabled="true" Sp="OPESch.OPETiUbicacionRel2Cmb" ColumnValue="ClaUbicacionRel2" ColumnDescription="NomUbicacionRel2" ParentCmb="" MinChars="0" LoadingTime="0" /> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 565.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
	<asp:UpdatePanel ID="uEle12" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebLabel ID="Ele12" runat="server" Text="Factura Origen:" Visible="true" CssClass="" > </cc1:WebLabel> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 665.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uNumFacturaOrigen" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="NumFacturaOrigen" IsFilter="true" runat="server" width="110.000px" Visible="true" CssClass="" Enabled="true" MaxLength = "20" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 845.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uVerBajas" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebCheckBox ID="VerBajas" IsFilter="true" AutoPostBack="true" OnCheckedChanged="control_ValueChanged" runat="server" Text="Ver Bajas Lógicas" width="110.000px" Visible="true" Enabled="true" > </cc1:WebCheckBox > </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 0.000px; top: 64.000px; display: inline; float: left; height: 417.000px; width: 960.000px;" class="dM "> 
 <asp:UpdatePanel ID="uFacturasSumDirecto" runat="server" UpdateMode="Conditional" > <ContentTemplate> 
 <cc1:WebGrid ID="FacturasSumDirecto" runat="server" Height="417.000px" Width="960.000px" AllowInsert ="true" AllowEdit ="true" 
			 AllowDelete ="true" SpSearch = "OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_Sel" SpIU = "OPESch.OPE_CU550_Pag37_Grid_FacturasSumDirecto_IU" PageSize ="30" Visible="true" 
			 OnColumnLinkButtonClick="grid_LinkButtonClick" OnColumnValueChange="grid_ValueChange" OnInitializeRow="grid_InitializeRow" 
			 PanelRelation="1" OnSelectedRowChange="grid_SelectedRowChange" 
			 AutoLeft="true" AutoHeight="true" AutoRight="true" AllowInsertWithTab ="false" 
 > 
<columns>
<cc1:WebGridTextColumn				Width="115.000px"			 IsRequired="true" Key="NumFacturaFilial"		Text="Factura Filial"																	EditMode="OnInsert" Visible="true" MaxLenght = "20"			 	NeedsValueChange="true" />
<cc1:WebGridTextColumn				Width="115.000px"			 IsRequired="true" Key="NumFacturaOrigen"		Text="Factura Origen"																	EditMode="OnInsert" Visible="true" MaxLenght = "20"			 	NeedsValueChange="true" />
<cc1:WebGridNumericColumn			Width="35.000px"			 Key="ClaUbicacionOrigen"		Text="Ubicación Origen"	Type="Clave"												EditMode="Never" Visible="false" Decimales = "0" NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="195.000px"			 Key="NomUbicacionOrigen"		Text="Ubicación Origen"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="115.000px"			 Key="NumCertificado"		Text="Certificado"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridImageColumn			Width="75.000px"			 Key="Descarga"		Text="Descargar"	UrlImage="/Common/Images/WebToolImages/attach24.png"												EditMode="Never" Visible="true" NeedsValueChange="true" />
<cc1:WebGridTextColumn				Width="95.000px"			 Align="Center" Key="Estatus"		Text="Estatus"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridTextColumn				Width="435.000px"			 Key="MensajeError"		Text="Mensaje de error"																	EditMode="Never" Visible="true" MaxLenght = "20"			 	NeedsValueChange="false" />
<cc1:WebGridLinkButtonColumn		Width="95.000px"			 Align="Center" Key="EsRegenerar"		Text="Regenerar Certificado"																	EditMode="Always" Visible="true" NeedsValueChange="true" Decimales="0" Type="Clave" />
<cc1:WebGridCheckBoxColumn			Width="95.000px"			 Align="Left" Key="BajaLogica"		Text="Baja Lógica"																	EditMode="Always" Visible="true" NeedsValueChange="false" ShowCheckBoxHeader="false" />
</columns>	</cc1:WebGrid> </ContentTemplate></asp:UpdatePanel></div>
<div style="position:absolute; left: 85.000px; top: 14.000px; display: inline; float: left; height: 17.000px; width: 110.000px;" class="dM ">
<asp:UpdatePanel ID="uFacturaFilial" IsIgnored="true" runat="server" UpdateMode="Conditional">	<ContentTemplate> <cc1:WebTextBox ID="FacturaFilial" IsIgnored="true" runat="server" width="110.000px" Visible="false" CssClass="" Enabled="true" MaxLength = "15" > </cc1:WebTextBox> </ContentTemplate></asp:UpdatePanel></div>
</div></div>
</asp:Content>
