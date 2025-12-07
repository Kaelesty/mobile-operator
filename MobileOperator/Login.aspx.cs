using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace MobileOperator
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Ничего особенного при загрузке
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
                SELECT subscriber_id, name, last_name
                FROM Subscriber
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
                            int userId = reader.GetInt32(reader.GetOrdinal("subscriber_id"));
                            string name = reader["name"].ToString();
                            string lastName = reader["last_name"].ToString();

                            // сохраняем данные пользователя в Session
                            Session["UserId"] = userId;
                            Session["UserName"] = name;
                            Session["UserLastName"] = lastName;

                            // переходим в личный кабинет
                            Response.Redirect("~/Cabinet.aspx");
                        }
                        else
                        {
                            lblError.Text = "Неверный e-mail или пароль.";
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
