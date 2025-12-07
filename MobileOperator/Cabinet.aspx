<%@ Page Title="Личный кабинет"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Cabinet.aspx.cs"
    Inherits="MobileOperator.Cabinet" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <h2>Личный кабинет</h2>

    <asp:Label ID="lblHello" runat="server" CssClass="hello-text" />

    <h3>Данные абонента</h3>

    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
        CssClass="text-danger"
        ValidationGroup="SubscriberData" />

    <asp:SqlDataSource ID="SqlDataSourceSubscriber" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT subscriber_id,
                   last_name,
                   name,
                   second_name,
                   email,
                   passport_series,
                   passport_number
            FROM Subscriber
            WHERE subscriber_id = @id">
        <SelectParameters>
            <asp:SessionParameter Name="id" SessionField="UserId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>

    <div class="form-row">
        <label for="txtLastName">Фамилия:</label>
        <asp:TextBox ID="txtLastName" runat="server" CssClass="text-box" MaxLength="40" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
            ControlToValidate="txtLastName"
            ErrorMessage="Укажите фамилию"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="SubscriberData" />
    </div>

    <div class="form-row">
        <label for="txtFirstName">Имя:</label>
        <asp:TextBox ID="txtFirstName" runat="server" CssClass="text-box" MaxLength="40" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
            ControlToValidate="txtFirstName"
            ErrorMessage="Укажите имя"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="SubscriberData" />
    </div>

    <div class="form-row">
        <label for="txtMiddleName">Отчество:</label>
        <asp:TextBox ID="txtMiddleName" runat="server" CssClass="text-box" MaxLength="40" />
    </div>

    <div class="form-row">
        <label for="txtEmail">E-mail:</label>
        <asp:TextBox ID="txtEmail" runat="server" CssClass="text-box" MaxLength="100" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
            ControlToValidate="txtEmail"
            ErrorMessage="Укажите e-mail"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="SubscriberData" />
        <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server"
            ControlToValidate="txtEmail"
            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
            ErrorMessage="Укажите корректный e-mail"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="SubscriberData" />
    </div>

    <div class="form-row">
        <label>Серия паспорта:</label>
        <asp:Label ID="lblPassportSeries" runat="server" CssClass="text-box" />
    </div>

    <div class="form-row">
        <label>Номер паспорта:</label>
        <asp:Label ID="lblPassportNumber" runat="server" CssClass="text-box" />
    </div>

    <div class="form-row">
        <asp:Button ID="btnSave" runat="server"
            Text="Сохранить изменения"
            CssClass="btn"
            OnClick="btnSave_Click"
            ValidationGroup="SubscriberData" />
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="text-success" />

    <h3>Ваши договоры</h3>

    <asp:SqlDataSource ID="SqlDataSourceTariffs" runat="server"
    ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
    SelectCommand="
        SELECT tariff_id,
               gb + ', ' + minutes + ', ' + sms + ', ' +
               CAST(monthly_cost AS NVARCHAR(10)) + 'P/M' AS tariff_info,
               gb, minutes, sms, monthly_cost
        FROM Tariff
        WHERE tariff_status_id = 1">
</asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlDataSourceOffices" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT o.office_id,
                   c.title + ', ' + d.title + ', ' + o.street + ', ' + o.house AS office_info
            FROM Office o
            INNER JOIN District d ON o.district_id = d.district_id
            INNER JOIN City c ON d.city_id = c.city_id">
    </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlDataSourceContracts" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT c.contract_id,
                   c.date,
                   s.phone_number,
                   t.gb + ', ' + t.minutes + ', ' + t.sms + ', ' +
                   CAST(t.monthly_cost AS NVARCHAR(10)) + ' rub/month' AS tariff_info,
                   c.tariff_id,
                   cs.title AS contract_status
            FROM Contract c
            INNER JOIN Tariff t ON c.tariff_id = t.tariff_id
            INNER JOIN Contract_status cs ON c.contract_status_id = cs.contract_status_id
            INNER JOIN Sim_card s ON c.sim_id = s.sim_id
            WHERE s.subscriber_id = @id">
        <SelectParameters>
            <asp:SessionParameter Name="id" SessionField="UserId" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>

    <asp:GridView ID="GridViewContracts" runat="server"
        DataSourceID="SqlDataSourceContracts"
        AutoGenerateColumns="False"
        CssClass="table"
        AllowPaging="True"
        OnRowCommand="GridViewContracts_RowCommand">
        <Columns>
            <asp:BoundField DataField="contract_id" HeaderText="№ договора" ReadOnly="True" />
            <asp:BoundField DataField="date" HeaderText="Дата" DataFormatString="{0:dd.MM.yyyy}" />
            <asp:BoundField DataField="phone_number" HeaderText="Номер" />
            <asp:TemplateField HeaderText="Тариф">
                <ItemTemplate>
                    <asp:DropDownList ID="ddlContractTariff" runat="server"
                        DataSourceID="SqlDataSourceTariffs"
                        DataTextField="tariff_info"
                        DataValueField="tariff_id"
                        SelectedValue='<%# Eval("tariff_id") %>'
                        CssClass="text-box">
                    </asp:DropDownList>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="contract_status" HeaderText="Статус" />
            <asp:TemplateField HeaderText="Действия">
                <ItemTemplate>
                    <asp:Button ID="btnSaveTariff" runat="server"
                        Text="Сохранить изменения"
                        CommandName="UpdateTariff"
                        CommandArgument='<%# Eval("contract_id") %>'
                        CssClass="btn" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <h3>Заключить новый договор</h3>

    <asp:ValidationSummary ID="ValidationSummary2" runat="server"
        CssClass="text-danger"
        ValidationGroup="ContractData" />

    <div class="form-row">
        <label for="ddlTariff">Выберите тариф:</label>
        <asp:DropDownList ID="ddlTariff" runat="server"
            CssClass="text-box"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlTariff_SelectedIndexChanged"
            DataSourceID="SqlDataSourceTariffs"
            DataTextField="tariff_info"
            DataValueField="tariff_id">
        </asp:DropDownList>
        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
            ControlToValidate="ddlTariff"
            ErrorMessage="Выберите тариф"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="ContractData" />
    </div>

    <div class="form-row">
        <asp:Label ID="lblTariffInfo" runat="server" CssClass="tariff-info" />
    </div>

    <div class="form-row">
        <label for="txtPhoneNumber">Желаемый номер телефона:</label>
        <asp:TextBox ID="txtPhoneNumber" runat="server"
            CssClass="text-box"
            MaxLength="36"
            placeholder="+7XXXXXXXXXX" />
        <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server"
            ControlToValidate="txtPhoneNumber"
            ErrorMessage="Укажите номер телефона"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="ContractData" />
        <asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server"
            ControlToValidate="txtPhoneNumber"
            ValidationExpression="^\+7\d{10}$"
            ErrorMessage="Номер должен быть в формате +7XXXXXXXXXX"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="ContractData" />
        <asp:CustomValidator ID="cvPhoneNumber" runat="server"
            ControlToValidate="txtPhoneNumber"
            ErrorMessage="Этот номер телефона уже занят"
            Display="Dynamic"
            CssClass="text-danger"
            OnServerValidate="cvPhoneNumber_ServerValidate"
            ValidationGroup="ContractData" />
    </div>

    <div class="form-row">
        <label for="ddlOffice">Выберите офис для получения сим-карты:</label>
        <asp:DropDownList ID="ddlOffice" runat="server"
            CssClass="text-box"
            DataSourceID="SqlDataSourceOffices"
            DataTextField="office_info"
            DataValueField="office_id">
        </asp:DropDownList>
        <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server"
            ControlToValidate="ddlOffice"
            ErrorMessage="Выберите офис"
            Display="Dynamic"
            CssClass="text-danger"
            ValidationGroup="ContractData" />
    </div>

    <div class="form-row">
        <asp:Button ID="btnCreateContract" runat="server"
            Text="Заключить договор"
            CssClass="btn"
            OnClick="btnCreateContract_Click"
            ValidationGroup="ContractData" />
    </div>

    <asp:Label ID="lblContractMessage" runat="server" CssClass="text-success" />
</asp:Content>
