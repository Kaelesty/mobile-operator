<%@ Page Title="Администрирование"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Admin.aspx.cs"
    Inherits="MobileOperator.Admin" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <h2>Администрирование</h2>

    <!-- Раздел тарифов -->
    <h3>Тарифы</h3>

    <asp:SqlDataSource ID="SqlDataSourceAdminTariffStatus" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT tariff_status_id, description
            FROM Tariff_status
            ORDER BY tariff_status_id" />

    <asp:SqlDataSource ID="SqlDataSourceAdminTariffs" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT t.tariff_id,
                   t.gb,
                   t.minutes,
                   t.sms,
                   t.monthly_cost,
                   ts.description AS status,
                   t.tariff_status_id
            FROM Tariff t
            INNER JOIN Tariff_status ts
                ON t.tariff_status_id = ts.tariff_status_id
            ORDER BY t.tariff_id"
        InsertCommand="
            INSERT INTO Tariff (gb, minutes, sms, monthly_cost, tariff_status_id)
            VALUES (@gb, @minutes, @sms, @monthly_cost, @tariff_status_id)">
        <InsertParameters>
            <asp:Parameter Name="gb" Type="String" />
            <asp:Parameter Name="minutes" Type="String" />
            <asp:Parameter Name="sms" Type="String" />
            <asp:Parameter Name="monthly_cost" Type="Decimal" />
            <asp:Parameter Name="tariff_status_id" Type="Int32" />
        </InsertParameters>
    </asp:SqlDataSource>

    <asp:GridView ID="GridViewAdminTariffs" runat="server"
        DataSourceID="SqlDataSourceAdminTariffs"
        AutoGenerateColumns="False"
        CssClass="table editable-table"
        AllowPaging="True"
        AllowSorting="False"
        DataKeyNames="tariff_id"
        OnRowCommand="GridViewAdminTariffs_RowCommand"
        OnRowEditing="GridViewAdminTariffs_RowEditing"
        OnRowCancelingEdit="GridViewAdminTariffs_RowCancelingEdit"
        OnRowUpdating="GridViewAdminTariffs_RowUpdating">

        <Columns>
            <asp:BoundField DataField="tariff_id" HeaderText="ID" ReadOnly="True" />
            
            <asp:TemplateField HeaderText="Гигабайты">
                <ItemTemplate>
                    <asp:Label ID="lblGb" runat="server" Text='<%# Eval("gb") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtGb" runat="server" Text='<%# Bind("gb") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Минуты">
                <ItemTemplate>
                    <asp:Label ID="lblMinutes" runat="server" Text='<%# Eval("minutes") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtMinutes" runat="server" Text='<%# Bind("minutes") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="SMS">
                <ItemTemplate>
                    <asp:Label ID="lblSms" runat="server" Text='<%# Eval("sms") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtSms" runat="server" Text='<%# Bind("sms") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Абонплата, ₽">
                <ItemTemplate>
                    <asp:Label ID="lblMonthlyCost" runat="server" Text='<%# Eval("monthly_cost", "{0:F2}") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtMonthlyCost" runat="server" Text='<%# Bind("monthly_cost", "{0:F2}") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Статус">
                <ItemTemplate>
                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("status") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList ID="ddlStatus" runat="server"
                        DataSourceID="SqlDataSourceAdminTariffStatus"
                        DataTextField="description"
                        DataValueField="tariff_status_id"
                        SelectedValue='<%# Bind("tariff_status_id") %>'
                        CssClass="edit-dropdown">
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Действия">
                <ItemTemplate>
                    <asp:Button ID="btnEdit" runat="server" Text="Редактировать" CommandName="Edit" CssClass="btn-edit" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:Button ID="btnUpdate" runat="server" Text="Сохранить" CommandName="Update" CssClass="btn-save" />
                    <asp:Button ID="btnCancel" runat="server" Text="Отмена" CommandName="Cancel" CssClass="btn-cancel" />
                </EditItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <div class="form-row">
        <asp:TextBox ID="txtTariffGb" runat="server" Placeholder="ГБ, например '10 ГБ'" CssClass="text-box" />
        <asp:TextBox ID="txtTariffMinutes" runat="server" Placeholder="Минуты" CssClass="text-box" />
        <asp:TextBox ID="txtTariffSms" runat="server" Placeholder="SMS" CssClass="text-box" />
        <asp:TextBox ID="txtTariffCost" runat="server" Placeholder="Абонплата" CssClass="text-box" />
        <asp:DropDownList ID="ddlTariffStatus" runat="server"
            DataSourceID="SqlDataSourceAdminTariffStatus"
            DataTextField="description"
            DataValueField="tariff_status_id"
            CssClass="text-box" />
        <asp:Button ID="btnAddTariff" runat="server"
            Text="Добавить тариф"
            CssClass="btn"
            OnClick="btnAddTariff_Click" />
    </div>

    <!-- Раздел абонентов -->
    <h3>Абоненты</h3>

    <asp:SqlDataSource ID="SqlDataSourceAdminSubscribers" runat="server"
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
            ORDER BY subscriber_id"
        InsertCommand="
            INSERT INTO Subscriber (last_name, name, second_name, email, password, passport_series, passport_number)
            VALUES (@last_name, @name, @second_name, @email, @password, @passport_series, @passport_number)">
        <InsertParameters>
            <asp:Parameter Name="last_name" Type="String" />
            <asp:Parameter Name="name" Type="String" />
            <asp:Parameter Name="second_name" Type="String" />
            <asp:Parameter Name="email" Type="String" />
            <asp:Parameter Name="password" Type="String" />
            <asp:Parameter Name="passport_series" Type="String" />
            <asp:Parameter Name="passport_number" Type="String" />
        </InsertParameters>
    </asp:SqlDataSource>

    <asp:GridView ID="GridViewAdminSubscribers" runat="server"
        DataSourceID="SqlDataSourceAdminSubscribers"
        AutoGenerateColumns="False"
        CssClass="table editable-table"
        AllowPaging="True"
        AllowSorting="False"
        DataKeyNames="subscriber_id"
        OnRowCommand="GridViewAdminSubscribers_RowCommand"
        OnRowEditing="GridViewAdminSubscribers_RowEditing"
        OnRowCancelingEdit="GridViewAdminSubscribers_RowCancelingEdit"
        OnRowUpdating="GridViewAdminSubscribers_RowUpdating">

        <Columns>
            <asp:BoundField DataField="subscriber_id" HeaderText="ID" ReadOnly="True" />
            
            <asp:TemplateField HeaderText="Фамилия">
                <ItemTemplate>
                    <asp:Label ID="lblLastName" runat="server" Text='<%# Eval("last_name") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtLastName" runat="server" Text='<%# Bind("last_name") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Имя">
                <ItemTemplate>
                    <asp:Label ID="lblName" runat="server" Text='<%# Eval("name") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtName" runat="server" Text='<%# Bind("name") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Отчество">
                <ItemTemplate>
                    <asp:Label ID="lblSecondName" runat="server" Text='<%# Eval("second_name") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtSecondName" runat="server" Text='<%# Bind("second_name") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="E-mail">
                <ItemTemplate>
                    <asp:Label ID="lblEmail" runat="server" Text='<%# Eval("email") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtEmail" runat="server" Text='<%# Bind("email") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Серия паспорта">
                <ItemTemplate>
                    <asp:Label ID="lblPassportSeries" runat="server" Text='<%# Eval("passport_series") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtPassportSeries" runat="server" Text='<%# Bind("passport_series") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Номер паспорта">
                <ItemTemplate>
                    <asp:Label ID="lblPassportNumber" runat="server" Text='<%# Eval("passport_number") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtPassportNumber" runat="server" Text='<%# Bind("passport_number") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Действия">
                <ItemTemplate>
                    <asp:Button ID="btnEdit" runat="server" Text="Редактировать" CommandName="Edit" CssClass="btn-edit" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:Button ID="btnUpdate" runat="server" Text="Сохранить" CommandName="Update" CssClass="btn-save" />
                    <asp:Button ID="btnCancel" runat="server" Text="Отмена" CommandName="Cancel" CssClass="btn-cancel" />
                </EditItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <div class="form-row">
        <asp:TextBox ID="txtSubLastName" runat="server" Placeholder="Фамилия" CssClass="text-box" />
        <asp:TextBox ID="txtSubName" runat="server" Placeholder="Имя" CssClass="text-box" />
        <asp:TextBox ID="txtSubSecondName" runat="server" Placeholder="Отчество" CssClass="text-box" />
        <asp:TextBox ID="txtSubEmail" runat="server" Placeholder="E-mail" CssClass="text-box" />
        <asp:TextBox ID="txtSubPassword" runat="server" TextMode="Password" Placeholder="Пароль" CssClass="text-box" />
        <asp:TextBox ID="txtSubPassportSeries" runat="server" Placeholder="Серия" CssClass="text-box" />
        <asp:TextBox ID="txtSubPassportNumber" runat="server" Placeholder="Номер" CssClass="text-box" />
        <asp:Button ID="btnAddSubscriber" runat="server"
            Text="Создать абонента"
            CssClass="btn"
            OnClick="btnAddSubscriber_Click" />
    </div>

    <!-- Раздел договоров -->
    <h3>Договоры</h3>

    <asp:SqlDataSource ID="SqlDataSourceAdminContractStatus" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT contract_status_id, description
            FROM Contract_status
            ORDER BY contract_status_id" />

    <asp:SqlDataSource ID="SqlDataSourceAdminContracts" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT c.contract_id,
                   c.tariff_id,
                   c.contract_status_id,
                   c.[date] AS contract_date,
                   c.sim_id,
                   s.phone_number,
                   s.subscriber_id,
                   sub.last_name + ' ' + sub.name AS subscriber_name,
                   cs.description AS status
            FROM Contract c
            LEFT JOIN Sim_card s ON c.sim_id = s.sim_id
            LEFT JOIN Subscriber sub ON s.subscriber_id = sub.subscriber_id
            LEFT JOIN Contract_status cs ON c.contract_status_id = cs.contract_status_id
            ORDER BY c.contract_id" />

    <asp:GridView ID="GridViewAdminContracts" runat="server"
        DataSourceID="SqlDataSourceAdminContracts"
        AutoGenerateColumns="False"
        CssClass="table editable-table"
        AllowPaging="True"
        AllowSorting="False"
        DataKeyNames="contract_id"
        OnRowCommand="GridViewAdminContracts_RowCommand"
        OnRowEditing="GridViewAdminContracts_RowEditing"
        OnRowCancelingEdit="GridViewAdminContracts_RowCancelingEdit"
        OnRowUpdating="GridViewAdminContracts_RowUpdating">

        <Columns>
            <asp:BoundField DataField="contract_id" HeaderText="ID" ReadOnly="True" />
            
            <asp:TemplateField HeaderText="Абонент">
                <ItemTemplate>
                    <asp:Label ID="lblSubscriberName" runat="server" Text='<%# Eval("subscriber_name") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList ID="ddlSubscriber" runat="server"
                        DataSourceID="SqlDataSourceAdminSubscribers"
                        DataTextField="email"
                        DataValueField="subscriber_id"
                        SelectedValue='<%# Bind("subscriber_id") %>'
                        CssClass="edit-dropdown">
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Номер">
                <ItemTemplate>
                    <asp:Label ID="lblPhoneNumber" runat="server" Text='<%# Eval("phone_number") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtPhoneNumber" runat="server" Text='<%# Bind("phone_number") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="ID тарифа">
                <ItemTemplate>
                    <asp:Label ID="lblTariffId" runat="server" Text='<%# Eval("tariff_id") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList ID="ddlTariff" runat="server"
                        DataSourceID="SqlDataSourceAdminTariffs"
                        DataTextField="tariff_id"
                        DataValueField="tariff_id"
                        SelectedValue='<%# Bind("tariff_id") %>'
                        CssClass="edit-dropdown">
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Дата">
                <ItemTemplate>
                    <asp:Label ID="lblContractDate" runat="server" Text='<%# Eval("contract_date", "{0:dd.MM.yyyy}") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtContractDate" runat="server" Text='<%# Bind("contract_date", "{0:dd.MM.yyyy}") %>' CssClass="edit-textbox"></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Статус">
                <ItemTemplate>
                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("status") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList ID="ddlStatus" runat="server"
                        DataSourceID="SqlDataSourceAdminContractStatus"
                        DataTextField="description"
                        DataValueField="contract_status_id"
                        SelectedValue='<%# Bind("contract_status_id") %>'
                        CssClass="edit-dropdown">
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>
            
            <asp:TemplateField HeaderText="Действия">
                <ItemTemplate>
                    <asp:Button ID="btnEdit" runat="server" Text="Редактировать" CommandName="Edit" CssClass="btn-edit" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:Button ID="btnUpdate" runat="server" Text="Сохранить" CommandName="Update" CssClass="btn-save" />
                    <asp:Button ID="btnCancel" runat="server" Text="Отмена" CommandName="Cancel" CssClass="btn-cancel" />
                </EditItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <div class="form-row">
        <asp:DropDownList ID="ddlContractSubscriber" runat="server"
            DataSourceID="SqlDataSourceAdminSubscribers"
            DataTextField="email"
            DataValueField="subscriber_id"
            CssClass="text-box" />
        <asp:TextBox ID="txtContractPhone" runat="server" Placeholder="Номер телефона" CssClass="text-box" />
        <asp:DropDownList ID="ddlContractTariff" runat="server"
            DataSourceID="SqlDataSourceAdminTariffs"
            DataTextField="tariff_id"
            DataValueField="tariff_id"
            CssClass="text-box" />
        <asp:DropDownList ID="ddlContractStatusNew" runat="server"
            DataSourceID="SqlDataSourceAdminContractStatus"
            DataTextField="description"
            DataValueField="contract_status_id"
            CssClass="text-box" />
        <asp:Button ID="btnAddContract" runat="server"
            Text="Создать договор"
            CssClass="btn"
            OnClick="btnAddContract_Click" />
    </div>
</asp:Content>
