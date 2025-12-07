<%@ Page Title="Регистрация"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Register.aspx.cs"
    Inherits="MobileOperator.Register" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <h2>Регистрация нового пользователя</h2>

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
        <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server"
            ControlToValidate="txtEmail"
            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
            ErrorMessage="Укажите корректный e-mail"
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
        <asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server"
            ControlToValidate="txtPassword"
            ValidationExpression="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$"
            ErrorMessage="Пароль должен содержать минимум 6 символов, включая заглавные и строчные буквы и цифры"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <label for="txtConfirmPassword">Подтверждение пароля:</label>
        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="text-box" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
            ControlToValidate="txtConfirmPassword"
            ErrorMessage="Подтвердите пароль"
            Display="Dynamic"
            CssClass="text-danger" />
        <asp:CompareValidator ID="CompareValidator1" runat="server"
            ControlToValidate="txtConfirmPassword"
            ControlToCompare="txtPassword"
            ErrorMessage="Пароли не совпадают"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <label for="txtLastName">Фамилия:</label>
        <asp:TextBox ID="txtLastName" runat="server" CssClass="text-box" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
            ControlToValidate="txtLastName"
            ErrorMessage="Укажите фамилию"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <label for="txtFirstName">Имя:</label>
        <asp:TextBox ID="txtFirstName" runat="server" CssClass="text-box" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server"
            ControlToValidate="txtFirstName"
            ErrorMessage="Укажите имя"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <label for="txtMiddleName">Отчество:</label>
        <asp:TextBox ID="txtMiddleName" runat="server" CssClass="text-box" />
    </div>

    <div class="form-row">
        <label for="txtPassportSeries">Серия паспорта:</label>
        <asp:TextBox ID="txtPassportSeries" runat="server" CssClass="text-box" MaxLength="4" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server"
            ControlToValidate="txtPassportSeries"
            ErrorMessage="Укажите серию паспорта"
            Display="Dynamic"
            CssClass="text-danger" />
        <asp:RegularExpressionValidator ID="RegularExpressionValidator3" runat="server"
            ControlToValidate="txtPassportSeries"
            ValidationExpression="^\d{4}$"
            ErrorMessage="Серия паспорта должна состоять из 4 цифр"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <label for="txtPassportNumber">Номер паспорта:</label>
        <asp:TextBox ID="txtPassportNumber" runat="server" CssClass="text-box" MaxLength="6" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server"
            ControlToValidate="txtPassportNumber"
            ErrorMessage="Укажите номер паспорта"
            Display="Dynamic"
            CssClass="text-danger" />
        <asp:RegularExpressionValidator ID="RegularExpressionValidator4" runat="server"
            ControlToValidate="txtPassportNumber"
            ValidationExpression="^\d{6}$"
            ErrorMessage="Номер паспорта должен состоять из 6 цифр"
            Display="Dynamic"
            CssClass="text-danger" />
    </div>

    <div class="form-row">
        <asp:Button ID="btnRegister" runat="server"
            Text="Зарегистрироваться"
            CssClass="btn"
            OnClick="btnRegister_Click" />
    </div>

    <div class="form-row">
        <asp:HyperLink ID="lnkLogin" runat="server" NavigateUrl="~/Login.aspx" Text="Уже есть аккаунт? Войти" />
    </div>

    <asp:Label ID="lblError" runat="server" CssClass="text-danger" />
    <asp:Label ID="lblSuccess" runat="server" CssClass="text-success" />
</asp:Content>