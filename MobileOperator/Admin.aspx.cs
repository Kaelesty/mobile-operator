using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MobileOperator
{
    public partial class Admin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["EmployeeId"] == null)
            {
                Response.Redirect("~/AdminLogin.aspx");
                return;
            }
        }

        protected void btnAddTariff_Click(object sender, EventArgs e)
        {
            decimal monthlyCost;
            if (!decimal.TryParse(txtTariffCost.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out monthlyCost) &&
                !decimal.TryParse(txtTariffCost.Text.Trim(), NumberStyles.Number, CultureInfo.CurrentCulture, out monthlyCost))
            {
                return;
            }

            int statusId;
            if (!int.TryParse(ddlTariffStatus.SelectedValue, out statusId))
            {
                return;
            }

            SqlDataSourceAdminTariffs.InsertParameters["gb"].DefaultValue = txtTariffGb.Text.Trim();
            SqlDataSourceAdminTariffs.InsertParameters["minutes"].DefaultValue = txtTariffMinutes.Text.Trim();
            SqlDataSourceAdminTariffs.InsertParameters["sms"].DefaultValue = txtTariffSms.Text.Trim();
            SqlDataSourceAdminTariffs.InsertParameters["monthly_cost"].DefaultValue = monthlyCost.ToString(CultureInfo.InvariantCulture);
            SqlDataSourceAdminTariffs.InsertParameters["tariff_status_id"].DefaultValue = statusId.ToString();

            SqlDataSourceAdminTariffs.Insert();
            GridViewAdminTariffs.DataBind();
        }

        protected void btnAddSubscriber_Click(object sender, EventArgs e)
        {
            SqlDataSourceAdminSubscribers.InsertParameters["last_name"].DefaultValue = txtSubLastName.Text.Trim();
            SqlDataSourceAdminSubscribers.InsertParameters["name"].DefaultValue = txtSubName.Text.Trim();
            SqlDataSourceAdminSubscribers.InsertParameters["second_name"].DefaultValue = txtSubSecondName.Text.Trim();
            SqlDataSourceAdminSubscribers.InsertParameters["email"].DefaultValue = txtSubEmail.Text.Trim();
            SqlDataSourceAdminSubscribers.InsertParameters["password"].DefaultValue = txtSubPassword.Text.Trim();
            SqlDataSourceAdminSubscribers.InsertParameters["passport_series"].DefaultValue = txtSubPassportSeries.Text.Trim();
            SqlDataSourceAdminSubscribers.InsertParameters["passport_number"].DefaultValue = txtSubPassportNumber.Text.Trim();

            SqlDataSourceAdminSubscribers.Insert();
            GridViewAdminSubscribers.DataBind();
        }

        protected void btnAddContract_Click(object sender, EventArgs e)
        {
            int subscriberId;
            int tariffId;
            int statusId;

            if (!int.TryParse(ddlContractSubscriber.SelectedValue, out subscriberId))
            {
                return;
            }

            if (!int.TryParse(ddlContractTariff.SelectedValue, out tariffId))
            {
                return;
            }

            if (!int.TryParse(ddlContractStatusNew.SelectedValue, out statusId))
            {
                return;
            }

            string phoneNumber = txtContractPhone.Text.Trim();
            if (string.IsNullOrEmpty(phoneNumber))
            {
                return;
            }

            string connString = ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction tran = conn.BeginTransaction();

                try
                {
                    int employeeId = 0;
                    if (Session["EmployeeId"] != null)
                    {
                        int.TryParse(Session["EmployeeId"].ToString(), out employeeId);
                    }

                    int newSimId;
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO Sim_card (subscriber_id, phone_number, office_id, employee_id)
                        VALUES (@subscriber_id, @phone_number, NULL, @employee_id);
                        SELECT CAST(SCOPE_IDENTITY() AS int);", conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@subscriber_id", subscriberId);
                        cmd.Parameters.AddWithValue("@phone_number", phoneNumber);

                        if (employeeId > 0)
                        {
                            cmd.Parameters.AddWithValue("@employee_id", employeeId);
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@employee_id", DBNull.Value);
                        }

                        object simResult = cmd.ExecuteScalar();
                        newSimId = Convert.ToInt32(simResult);
                    }

                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO Contract (tariff_id, contract_status_id, [date], sim_id)
                        VALUES (@tariff_id, @status_id, @date, @sim_id)", conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@tariff_id", tariffId);
                        cmd.Parameters.AddWithValue("@status_id", statusId);
                        cmd.Parameters.AddWithValue("@date", DateTime.Now);
                        cmd.Parameters.AddWithValue("@sim_id", newSimId);

                        cmd.ExecuteNonQuery();
                    }

                    tran.Commit();
                }
                catch
                {
                    tran.Rollback();
                    throw;
                }
            }

            GridViewAdminContracts.DataBind();
        }

        protected void GridViewAdminContracts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ChangeStatus")
            {
                return;
            }

            int contractId;
            if (!int.TryParse(e.CommandArgument.ToString(), out contractId))
            {
                return;
            }

            GridViewRow row = ((Control)e.CommandSource).NamingContainer as GridViewRow;
            if (row == null)
            {
                return;
            }

            var ddlStatus = row.FindControl("ddlContractStatus") as DropDownList;
            if (ddlStatus == null)
            {
                return;
            }

            int statusId;
            if (!int.TryParse(ddlStatus.SelectedValue, out statusId))
            {
                return;
            }

            string connString = ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Contract SET contract_status_id = @status_id WHERE contract_id = @contract_id", conn))
            {
                cmd.Parameters.AddWithValue("@status_id", statusId);
                cmd.Parameters.AddWithValue("@contract_id", contractId);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            GridViewAdminContracts.DataBind();
        }

        // Tariffs table event handlers
        protected void GridViewAdminTariffs_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewAdminTariffs.EditIndex = e.NewEditIndex;
            GridViewAdminTariffs.DataBind();
        }

        protected void GridViewAdminTariffs_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewAdminTariffs.EditIndex = -1;
            GridViewAdminTariffs.DataBind();
        }

        protected void GridViewAdminTariffs_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            GridViewRow row = GridViewAdminTariffs.Rows[e.RowIndex];
            int tariffId = Convert.ToInt32(GridViewAdminTariffs.DataKeys[e.RowIndex].Value);

            var txtGb = (TextBox)row.FindControl("txtGb");
            var txtMinutes = (TextBox)row.FindControl("txtMinutes");
            var txtSms = (TextBox)row.FindControl("txtSms");
            var txtMonthlyCost = (TextBox)row.FindControl("txtMonthlyCost");
            var ddlStatus = (DropDownList)row.FindControl("ddlStatus");

            // Validation
            if (string.IsNullOrWhiteSpace(txtGb.Text) ||
                string.IsNullOrWhiteSpace(txtMinutes.Text) ||
                string.IsNullOrWhiteSpace(txtSms.Text) ||
                string.IsNullOrWhiteSpace(txtMonthlyCost.Text))
            {
                return;
            }

            decimal monthlyCost;
            if (!decimal.TryParse(txtMonthlyCost.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out monthlyCost) &&
                !decimal.TryParse(txtMonthlyCost.Text.Trim(), NumberStyles.Number, CultureInfo.CurrentCulture, out monthlyCost))
            {
                return;
            }

            int statusId;
            if (!int.TryParse(ddlStatus.SelectedValue, out statusId))
            {
                return;
            }

            string connString = ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Tariff SET gb = @gb, minutes = @minutes, sms = @sms, monthly_cost = @monthly_cost, tariff_status_id = @tariff_status_id WHERE tariff_id = @tariff_id", conn))
            {
                cmd.Parameters.AddWithValue("@gb", txtGb.Text.Trim());
                cmd.Parameters.AddWithValue("@minutes", txtMinutes.Text.Trim());
                cmd.Parameters.AddWithValue("@sms", txtSms.Text.Trim());
                cmd.Parameters.AddWithValue("@monthly_cost", monthlyCost);
                cmd.Parameters.AddWithValue("@tariff_status_id", statusId);
                cmd.Parameters.AddWithValue("@tariff_id", tariffId);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            GridViewAdminTariffs.EditIndex = -1;
            GridViewAdminTariffs.DataBind();
        }

        protected void GridViewAdminTariffs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Additional command handling if needed
        }

        // Subscribers table event handlers
        protected void GridViewAdminSubscribers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewAdminSubscribers.EditIndex = e.NewEditIndex;
            GridViewAdminSubscribers.DataBind();
        }

        protected void GridViewAdminSubscribers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewAdminSubscribers.EditIndex = -1;
            GridViewAdminSubscribers.DataBind();
        }

        protected void GridViewAdminSubscribers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            GridViewRow row = GridViewAdminSubscribers.Rows[e.RowIndex];
            int subscriberId = Convert.ToInt32(GridViewAdminSubscribers.DataKeys[e.RowIndex].Value);

            var txtLastName = (TextBox)row.FindControl("txtLastName");
            var txtName = (TextBox)row.FindControl("txtName");
            var txtSecondName = (TextBox)row.FindControl("txtSecondName");
            var txtEmail = (TextBox)row.FindControl("txtEmail");
            var txtPassportSeries = (TextBox)row.FindControl("txtPassportSeries");
            var txtPassportNumber = (TextBox)row.FindControl("txtPassportNumber");

            // Validation
            if (string.IsNullOrWhiteSpace(txtLastName.Text) ||
                string.IsNullOrWhiteSpace(txtName.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrWhiteSpace(txtPassportSeries.Text) ||
                string.IsNullOrWhiteSpace(txtPassportNumber.Text))
            {
                return;
            }

            string connString = ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Subscriber SET last_name = @last_name, name = @name, second_name = @second_name, email = @email, passport_series = @passport_series, passport_number = @passport_number WHERE subscriber_id = @subscriber_id", conn))
            {
                cmd.Parameters.AddWithValue("@last_name", txtLastName.Text.Trim());
                cmd.Parameters.AddWithValue("@name", txtName.Text.Trim());
                cmd.Parameters.AddWithValue("@second_name", txtSecondName.Text.Trim());
                cmd.Parameters.AddWithValue("@email", txtEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@passport_series", txtPassportSeries.Text.Trim());
                cmd.Parameters.AddWithValue("@passport_number", txtPassportNumber.Text.Trim());
                cmd.Parameters.AddWithValue("@subscriber_id", subscriberId);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            GridViewAdminSubscribers.EditIndex = -1;
            GridViewAdminSubscribers.DataBind();
        }

        protected void GridViewAdminSubscribers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Additional command handling if needed
        }

        // Contracts table event handlers
        protected void GridViewAdminContracts_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewAdminContracts.EditIndex = e.NewEditIndex;
            GridViewAdminContracts.DataBind();
        }

        protected void GridViewAdminContracts_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewAdminContracts.EditIndex = -1;
            GridViewAdminContracts.DataBind();
        }

        protected void GridViewAdminContracts_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            GridViewRow row = GridViewAdminContracts.Rows[e.RowIndex];
            int contractId = Convert.ToInt32(GridViewAdminContracts.DataKeys[e.RowIndex].Value);

            var ddlSubscriber = (DropDownList)row.FindControl("ddlSubscriber");
            var txtPhoneNumber = (TextBox)row.FindControl("txtPhoneNumber");
            var ddlTariff = (DropDownList)row.FindControl("ddlTariff");
            var txtContractDate = (TextBox)row.FindControl("txtContractDate");
            var ddlStatus = (DropDownList)row.FindControl("ddlStatus");

            // Validation
            if (string.IsNullOrWhiteSpace(txtPhoneNumber.Text) ||
                string.IsNullOrWhiteSpace(txtContractDate.Text))
            {
                return;
            }

            int subscriberId, tariffId, statusId;
            if (!int.TryParse(ddlSubscriber.SelectedValue, out subscriberId) ||
                !int.TryParse(ddlTariff.SelectedValue, out tariffId) ||
                !int.TryParse(ddlStatus.SelectedValue, out statusId))
            {
                return;
            }

            DateTime contractDate;
            if (!DateTime.TryParse(txtContractDate.Text.Trim(), out contractDate))
            {
                return;
            }

            string connString = ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction tran = conn.BeginTransaction();

                try
                {
                    // Update Sim_card table
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Sim_card SET subscriber_id = @subscriber_id, phone_number = @phone_number WHERE sim_id = (SELECT sim_id FROM Contract WHERE contract_id = @contract_id)", conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@subscriber_id", subscriberId);
                        cmd.Parameters.AddWithValue("@phone_number", txtPhoneNumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@contract_id", contractId);
                        cmd.ExecuteNonQuery();
                    }

                    // Update Contract table
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Contract SET tariff_id = @tariff_id, contract_status_id = @contract_status_id, [date] = @date WHERE contract_id = @contract_id", conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@tariff_id", tariffId);
                        cmd.Parameters.AddWithValue("@contract_status_id", statusId);
                        cmd.Parameters.AddWithValue("@date", contractDate);
                        cmd.Parameters.AddWithValue("@contract_id", contractId);
                        cmd.ExecuteNonQuery();
                    }

                    tran.Commit();
                }
                catch
                {
                    tran.Rollback();
                    throw;
                }
            }

            GridViewAdminContracts.EditIndex = -1;
            GridViewAdminContracts.DataBind();
        }
    }
}
