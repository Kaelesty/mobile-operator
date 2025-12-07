<%@ Page Title="Тарифы"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Tariffs.aspx.cs"
    Inherits="MobileOperator.Tariffs" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">

    <h2>Тарифные планы</h2>

    <!-- Блок фильтрации -->
    <div class="form-row">
        <label for="ddlStatus">Статус тарифа:</label>
        <asp:DropDownList ID="ddlStatus" runat="server"
            DataSourceID="SqlDataSourceTariffStatus"
            DataTextField="description"
            DataValueField="tariff_status_id"
            AppendDataBoundItems="true"
            AutoPostBack="true"
            CssClass="text-box">
            <asp:ListItem Text="Все" Value="" Selected="True"></asp:ListItem>
        </asp:DropDownList>
    </div>

    <div class="form-row">
        <label for="ddlMaxCost">Макс. стоимость, ₽:</label>
        <asp:DropDownList ID="ddlMaxCost" runat="server"
            AutoPostBack="true"
            CssClass="text-box">
            <asp:ListItem Text="Все" Value=""></asp:ListItem>
            <asp:ListItem Text="До 300"    Value="300"></asp:ListItem>
            <asp:ListItem Text="До 500"    Value="500"></asp:ListItem>
            <asp:ListItem Text="До 700"    Value="700"></asp:ListItem>
            <asp:ListItem Text="До 1000"   Value="1000"></asp:ListItem>
        </asp:DropDownList>
    </div>

    <div class="form-row">
        <label for="ddlMinMinutes">Мин. минут:</label>
        <asp:DropDownList ID="ddlMinMinutes" runat="server"
            AutoPostBack="true"
            CssClass="text-box">
            <asp:ListItem Text="Все" Value=""></asp:ListItem>
            <asp:ListItem Text="От 300"     Value="300"></asp:ListItem>
            <asp:ListItem Text="От 500"     Value="500"></asp:ListItem>
            <asp:ListItem Text="От 700"     Value="700"></asp:ListItem>
            <asp:ListItem Text="От 1000"    Value="1000"></asp:ListItem>
        </asp:DropDownList>
    </div>

    <div class="form-row">
        <label for="ddlMinGb">Мин. интернет, ГБ:</label>
        <asp:DropDownList ID="ddlMinGb" runat="server"
            AutoPostBack="true"
            CssClass="text-box">
            <asp:ListItem Text="Все" Value=""></asp:ListItem>
            <asp:ListItem Text="От 5 ГБ"    Value="5"></asp:ListItem>
            <asp:ListItem Text="От 10 ГБ"   Value="10"></asp:ListItem>
            <asp:ListItem Text="От 20 ГБ"   Value="20"></asp:ListItem>
            <asp:ListItem Text="От 30 ГБ"   Value="30"></asp:ListItem>
        </asp:DropDownList>
    </div>

    <div class="form-row">
        <label for="ddlMinSms">Мин. SMS:</label>
        <asp:DropDownList ID="ddlMinSms" runat="server"
            AutoPostBack="true"
            CssClass="text-box">
            <asp:ListItem Text="Все" Value=""></asp:ListItem>
            <asp:ListItem Text="От 30"      Value="30"></asp:ListItem>
            <asp:ListItem Text="От 50"      Value="50"></asp:ListItem>
            <asp:ListItem Text="От 100"     Value="100"></asp:ListItem>
            <asp:ListItem Text="От 300"     Value="300"></asp:ListItem>
        </asp:DropDownList>
    </div>

    <!-- Источник статусов тарифа -->
    <asp:SqlDataSource ID="SqlDataSourceTariffStatus" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        SelectCommand="
            SELECT tariff_status_id, description
            FROM Tariff_status
            ORDER BY tariff_status_id">
    </asp:SqlDataSource>

    <!-- Основной источник тарифов с фильтрацией -->
    <asp:SqlDataSource ID="SqlDataSourceTariffs" runat="server"
        ConnectionString="<%$ ConnectionStrings:MobileCompanyConnectionString %>"
        CancelSelectOnNullParameter="false"
        SelectCommand="
            SELECT t.tariff_id,
                   t.gb,
                   t.minutes,
                   t.sms,
                   t.monthly_cost,
                   ts.description AS status
            FROM Tariff t
            INNER JOIN Tariff_status ts
                ON t.tariff_status_id = ts.tariff_status_id
            WHERE
                (@statusId IS NULL OR t.tariff_status_id = @statusId)
                AND (@maxCost IS NULL OR t.monthly_cost <= @maxCost)
                AND (
                    @minMinutes IS NULL OR
                    TRY_CONVERT(int,
                        LEFT(t.minutes, CHARINDEX(' ', t.minutes + ' ') - 1)
                    ) >= @minMinutes
                )
                AND (
                    @minGb IS NULL OR
                    TRY_CONVERT(int,
                        LEFT(t.gb, CHARINDEX(' ', t.gb + ' ') - 1)
                    ) >= @minGb
                )
                AND (
                    @minSms IS NULL OR
                    TRY_CONVERT(int,
                        LEFT(t.sms, CHARINDEX(' ', t.sms + ' ') - 1)
                    ) >= @minSms
                )">
        <SelectParameters>
            <asp:ControlParameter Name="statusId"
                ControlID="ddlStatus"
                PropertyName="SelectedValue"
                Type="Int32"
                ConvertEmptyStringToNull="true" />
            <asp:ControlParameter Name="maxCost"
                ControlID="ddlMaxCost"
                PropertyName="SelectedValue"
                Type="Decimal"
                ConvertEmptyStringToNull="true" />
            <asp:ControlParameter Name="minMinutes"
                ControlID="ddlMinMinutes"
                PropertyName="SelectedValue"
                Type="Int32"
                ConvertEmptyStringToNull="true" />
            <asp:ControlParameter Name="minGb"
                ControlID="ddlMinGb"
                PropertyName="SelectedValue"
                Type="Int32"
                ConvertEmptyStringToNull="true" />
            <asp:ControlParameter Name="minSms"
                ControlID="ddlMinSms"
                PropertyName="SelectedValue"
                Type="Int32"
                ConvertEmptyStringToNull="true" />
        </SelectParameters>
    </asp:SqlDataSource>

    <!-- Таблица с тарифами -->
    <asp:GridView ID="GridViewTariffs" runat="server"
        DataSourceID="SqlDataSourceTariffs"
        AutoGenerateColumns="False"
        CssClass="table"
        AllowPaging="True"
        AllowSorting="True"
        DataKeyNames="tariff_id">

        <Columns>
            <asp:BoundField DataField="tariff_id" HeaderText="ID" ReadOnly="True" />
            <asp:BoundField DataField="gb" HeaderText="Интернет" />
            <asp:BoundField DataField="minutes" HeaderText="Минуты" />
            <asp:BoundField DataField="sms" HeaderText="SMS" />
            <asp:BoundField DataField="monthly_cost" HeaderText="Стоимость, ₽" DataFormatString="{0:F2}" />
            <asp:BoundField DataField="status" HeaderText="Статус" />
        </Columns>
    </asp:GridView>

</asp:Content>
