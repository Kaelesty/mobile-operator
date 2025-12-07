using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MobileOperator
{
    public partial class Cabinet : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // если пользователь не авторизован – отправляем на логин
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string name = Session["UserName"] as string;
                string lastName = Session["UserLastName"] as string;

                if (!string.IsNullOrEmpty(name))
                {
                    lblHello.Text = $"Здравствуйте, {lastName} {name}!";
                }
                else
                {
                    lblHello.Text = "Здравствуйте!";
                }

                LoadSubscriberData();
                LoadContractFormData();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Page.Validate("SubscriberData");
            if (!Page.IsValid)
                return;

            int userId = (int)Session["UserId"];
            string lastName = txtLastName.Text.Trim();
            string firstName = txtFirstName.Text.Trim();
            string middleName = txtMiddleName.Text.Trim();
            string email = txtEmail.Text.Trim();

            // Ограничиваем длину полей согласно структуре базы данных
            if (lastName.Length > 40) lastName = lastName.Substring(0, 40);
            if (firstName.Length > 40) firstName = firstName.Substring(0, 40);
            if (middleName != null && middleName.Length > 40) middleName = middleName.Substring(0, 40);
            if (email.Length > 100) email = email.Substring(0, 100);

            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string updateSql = @"
                UPDATE Subscriber
                SET last_name = @lastName,
                    name = @firstName,
                    second_name = @middleName,
                    email = @email
                WHERE subscriber_id = @userId";

            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@lastName", lastName);
                    cmd.Parameters.AddWithValue("@firstName", firstName);
                    cmd.Parameters.AddWithValue("@middleName", string.IsNullOrEmpty(middleName) ? (object)System.DBNull.Value : middleName);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@userId", userId);

                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        // Обновляем данные в сессии
                        Session["UserName"] = firstName;
                        Session["UserLastName"] = lastName;
                        
                        lblMessage.Text = "Данные успешно сохранены!";
                        lblHello.Text = $"Здравствуйте, {lastName} {firstName}!";
                    }
                    else
                    {
                        lblMessage.Text = "Ошибка при сохранении данных.";
                    }
                }
            }
            catch (System.Data.SqlClient.SqlException ex)
            {
                lblMessage.Text = "Ошибка базы данных: " + ex.Message;
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Произошла ошибка: " + ex.Message;
            }
        }

        private void LoadSubscriberData()
        {
            int userId = (int)Session["UserId"];
            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string selectSql = @"
                SELECT last_name, name, second_name, email, passport_series, passport_number
                FROM Subscriber
                WHERE subscriber_id = @userId";

            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(selectSql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    conn.Open();
                    
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtLastName.Text = reader["last_name"].ToString();
                            txtFirstName.Text = reader["name"].ToString();
                            txtMiddleName.Text = reader["second_name"].ToString();
                            txtEmail.Text = reader["email"].ToString();
                            lblPassportSeries.Text = reader["passport_series"].ToString();
                            lblPassportNumber.Text = reader["passport_number"].ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Ошибка при загрузке данных: " + ex.Message;
            }
        }

        protected void ddlTariff_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlTariff.SelectedValue != "")
            {
                int tariffId = int.Parse(ddlTariff.SelectedValue);
                ShowTariffInfo(tariffId);
            }
            else
            {
                lblTariffInfo.Text = "";
            }
        }

        protected void GridViewContracts_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "UpdateTariff")
            {
                int contractId = int.Parse(e.CommandArgument.ToString());
                
                // Находим DropDownList в строке
                GridViewRow row = ((Button)e.CommandSource).NamingContainer as GridViewRow;
                DropDownList ddlTariff = (DropDownList)row.FindControl("ddlContractTariff");
                
                if (ddlTariff == null)
                {
                    lblContractMessage.Text = "Ошибка: элемент выбора тарифа не найден";
                    return;
                }

                if (string.IsNullOrEmpty(ddlTariff.SelectedValue) || ddlTariff.SelectedValue == "0")
                {
                    lblContractMessage.Text = "Пожалуйста, выберите тариф";
                    return;
                }

                try
                {
                    int newTariffId = int.Parse(ddlTariff.SelectedValue);
                    if (newTariffId <= 0)
                    {
                        lblContractMessage.Text = "Выбран некорректный тариф";
                        return;
                    }

                    UpdateContractTariff(contractId, newTariffId);
                    
                    // Показываем сообщение об успехе
                    lblContractMessage.Text = "Тариф успешно изменен!";
                    
                    // Обновляем GridView
                    GridViewContracts.DataBind();
                }
                catch (Exception ex)
                {
                    lblContractMessage.Text = "Ошибка при изменении тарифа: " + ex.Message;
                }
            }
        }

        protected void cvPhoneNumber_ServerValidate(object source, System.Web.UI.WebControls.ServerValidateEventArgs args)
        {
            string phoneNumber = txtPhoneNumber.Text.Trim();
            if (string.IsNullOrEmpty(phoneNumber))
            {
                args.IsValid = true;
                return;
            }

            args.IsValid = !IsPhoneNumberTaken(phoneNumber);
        }

        protected void btnCreateContract_Click(object sender, EventArgs e)
        {
            Page.Validate("ContractData");
            if (!Page.IsValid)
                return;

            // Проверка на пустой тариф
            if (string.IsNullOrEmpty(ddlTariff.SelectedValue) || ddlTariff.SelectedValue == "0")
            {
                lblContractMessage.Text = "Пожалуйста, выберите тариф";
                return;
            }

            try
            {
                int userId = (int)Session["UserId"];
                int tariffId = int.Parse(ddlTariff.SelectedValue);
                
                // Дополнительная проверка на корректность тарифа
                if (tariffId <= 0)
                {
                    lblContractMessage.Text = "Выбран некорректный тариф";
                    return;
                }

                string phoneNumber = txtPhoneNumber.Text.Trim();
                int officeId = int.Parse(ddlOffice.SelectedValue);

                // Создаем сим-карту
                int simId = CreateSimCard(userId, phoneNumber, officeId);
                
                // Создаем договор
                CreateContract(tariffId, simId);

                lblContractMessage.Text = $"Успешно! Проследуйте в офис {GetOfficeInfo(officeId)} для получения сим-карты.";
                
                // Очищаем форму
                txtPhoneNumber.Text = "";
                ddlTariff.ClearSelection();
                ddlOffice.ClearSelection();
                lblTariffInfo.Text = "";
                
                // Обновляем таблицу договоров
                GridViewContracts.DataBind();
            }
            catch (Exception ex)
            {
                lblContractMessage.Text = "Ошибка при создании договора: " + ex.Message;
            }
        }

        private void LoadContractFormData()
        {
            if (!IsPostBack)
            {
                ddlTariff.DataBind();
                ddlOffice.DataBind();
            }
        }

        private void ShowTariffInfo(int tariffId)
        {
            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string sql = @"
                SELECT gb, minutes, sms, monthly_cost
                FROM Tariff
                WHERE tariff_id = @tariffId";

            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@tariffId", tariffId);
                    conn.Open();
                    
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string gb = reader["gb"].ToString();
                            string minutes = reader["minutes"].ToString();
                            string sms = reader["sms"].ToString();
                            decimal monthlyCost = (decimal)reader["monthly_cost"];
                            
                            lblTariffInfo.Text = $@"
                                <strong>Информация о тарифе:</strong><br/>
                                {gb}, {minutes}, {sms}, {monthlyCost} rub/month";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblTariffInfo.Text = "Ошибка при загрузке информации о тарифе";
            }
        }

        private bool IsPhoneNumberTaken(string phoneNumber)
        {
            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string sql = "SELECT COUNT(*) FROM Sim_card WHERE phone_number = @phoneNumber";

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@phoneNumber", phoneNumber);
                conn.Open();
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }

        private int CreateSimCard(int subscriberId, string phoneNumber, int officeId)
        {
            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            // Получаем случайного сотрудника
            int employeeId = GetRandomEmployeeId();

            string sql = @"
                INSERT INTO Sim_card (subscriber_id, phone_number, office_id, employee_id)
                OUTPUT INSERTED.sim_id
                VALUES (@subscriberId, @phoneNumber, @officeId, @employeeId)";

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@subscriberId", subscriberId);
                cmd.Parameters.AddWithValue("@phoneNumber", phoneNumber);
                cmd.Parameters.AddWithValue("@officeId", officeId);
                cmd.Parameters.AddWithValue("@employeeId", employeeId);
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        private void CreateContract(int tariffId, int simId)
        {
            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            // Статус "Активен" (предполагаем, что contract_status_id = 1)
            string sql = @"
                INSERT INTO Contract (tariff_id, contract_status_id, date, sim_id)
                VALUES (@tariffId, 1, GETDATE(), @simId)";

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@tariffId", tariffId);
                cmd.Parameters.AddWithValue("@simId", simId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private int GetRandomEmployeeId()
        {
            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string sql = "SELECT TOP 1 employee_id FROM Employee ORDER BY NEWID()";

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != null ? (int)result : 1; // Если нет сотрудников, используем ID 1
            }
        }

        private string GetOfficeInfo(int officeId)
        {
            string connString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string sql = @"
                SELECT c.title + ', ' + d.title + ', ' + o.street + ', ' + o.house AS office_info
                FROM Office o
                INNER JOIN District d ON o.district_id = d.district_id
                INNER JOIN City c ON d.city_id = c.city_id
                WHERE o.office_id = @officeId";

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@officeId", officeId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : "неизвестный офис";
            }
        }

        private void UpdateContractTariff(int contractId, int newTariffId)
        {
            string connectionString = System.Configuration.ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string updateSql = @"
                UPDATE Contract
                SET tariff_id = @newTariffId
                WHERE contract_id = @contractId";

            using (System.Data.SqlClient.SqlConnection connection = new System.Data.SqlClient.SqlConnection(connectionString))
            using (System.Data.SqlClient.SqlCommand command = new System.Data.SqlClient.SqlCommand(updateSql, connection))
            {
                command.Parameters.AddWithValue("@newTariffId", newTariffId);
                command.Parameters.AddWithValue("@contractId", contractId);
                connection.Open();
                int rowsAffected = command.ExecuteNonQuery();

                if (rowsAffected == 0)
                {
                    throw new Exception("Договор не найден или не был обновлен");
                }
            }
        }
    }
}
