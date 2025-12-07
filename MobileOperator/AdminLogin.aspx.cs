using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace MobileOperator
{
    public partial class AdminLogin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            string connString = ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            string sql = @"
                SELECT employee_id, name, last_name
                FROM Employee
                WHERE email = @email AND password = @password";

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@password", password);

                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int employeeId = reader.GetInt32(reader.GetOrdinal("employee_id"));
                            string name = reader["name"].ToString();
                            string lastName = reader["last_name"].ToString();

                            Session["EmployeeId"] = employeeId;
                            Session["EmployeeName"] = name;
                            Session["EmployeeLastName"] = lastName;

                            Response.Redirect("~/Admin.aspx");
                        }
                        else
                        {
                            lblError.Text = "Сотрудник с таким e-mail не найден.";
                        }
                    }
                }
            }
            catch (Exception)
            {
                lblError.Text = "Ошибка при обращении к базе данных.";
            }
        }
    }
}
