<%@ Page Title="Администрирование"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="AdminLogin.aspx.cs"
    Inherits="MobileOperator.AdminLogin" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <h2>Вход для сотрудников</h2>

    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
        CssClass="text-danger" />

    <div class="form-row">
        <label for="txtEmail">E-mail:</label>
        <asp:TextBox ID="txtEmail" runat="server" CssClass="text-box" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
            ControlToValidate="txtEmail"
            ErrorMessage="Укажите e-mail"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <label for="txtPassword">Пароль:</label>
        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="text-box" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
            ControlToValidate="txtPassword"
            ErrorMessage="Укажите пароль"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <asp:Button ID="btnLogin" runat="server"
            Text="Войти"
            CssClass="btn"
            OnClick="btnLogin_Click" />
    </div>

    <asp:Label ID="lblError" runat="server" CssClass="text-danger" />
</asp:Content>

