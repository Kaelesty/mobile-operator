<%@ Page Title="Офисы"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Offices.aspx.cs"
    Inherits="MobileOperator.Offices" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <h2>Офисы обслуживания</h2>

    <asp:SqlDataSource ID="SqlDataSourceOffices" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT o.office_id,
                   c.title AS city,
                   d.title AS district,
                   o.street,
                   o.house
            FROM Office o
            LEFT JOIN District d ON o.district_id = d.district_id
            LEFT JOIN City c ON d.city_id = c.city_id
            ORDER BY c.title, d.title, o.street, o.house">
    </asp:SqlDataSource>

    <asp:GridView ID="GridViewOffices" runat="server"
        DataSourceID="SqlDataSourceOffices"
        AutoGenerateColumns="False"
        CssClass="table"
        AllowPaging="True">
        <Columns>
            <asp:BoundField DataField="office_id" HeaderText="ID" ReadOnly="True" />
            <asp:BoundField DataField="city" HeaderText="Город" />
            <asp:BoundField DataField="district" HeaderText="Район" />
            <asp:BoundField DataField="street" HeaderText="Улица" />
            <asp:BoundField DataField="house" HeaderText="Дом" />
        </Columns>
    </asp:GridView>
</asp:Content>

