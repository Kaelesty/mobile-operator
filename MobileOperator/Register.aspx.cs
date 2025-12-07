using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace MobileOperator
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Если пользователь уже авторизован, перенаправляем в кабинет
            if (Session["UserId"] != null)
            {
                Response.Redirect("~/Cabinet.aspx");
                return;
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string lastName = txtLastName.Text.Trim();
            string firstName = txtFirstName.Text.Trim();
            string middleName = txtMiddleName.Text.Trim();
            string passportSeries = txtPassportSeries.Text.Trim();
            string passportNumber = txtPassportNumber.Text.Trim();

            string connString = ConfigurationManager
                .ConnectionStrings["MobileCompanyConnectionString"]
                .ConnectionString;

            // Проверяем, существует ли уже пользователь с таким email
            string checkEmailSql = @"
                SELECT COUNT(*) 
                FROM Subscriber 
                WHERE email = @email";

            string insertSql = @"
                INSERT INTO Subscriber (email, password, last_name, name, second_name, passport_series, passport_number)
                VALUES (@email, @password, @lastName, @firstName, @middleName, @passportSeries, @passportNumber)";

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Проверяем существование email
                    using (SqlCommand checkCmd = new SqlCommand(checkEmailSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@email", email);
                        int existingCount = (int)checkCmd.ExecuteScalar();

                        if (existingCount > 0)
                        {
                            lblError.Text = "Пользователь с таким e-mail уже существует.";
                            return;
                        }
                    }

                    // Регистрируем нового пользователя
                    using (SqlCommand insertCmd = new SqlCommand(insertSql, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@email", email);
                        insertCmd.Parameters.AddWithValue("@password", password);
                        insertCmd.Parameters.AddWithValue("@lastName", lastName);
                        insertCmd.Parameters.AddWithValue("@firstName", firstName);
                        insertCmd.Parameters.AddWithValue("@middleName", string.IsNullOrEmpty(middleName) ? (object)DBNull.Value : middleName);
                        insertCmd.Parameters.AddWithValue("@passportSeries", passportSeries);
                        insertCmd.Parameters.AddWithValue("@passportNumber", passportNumber);

                        int rowsAffected = insertCmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            lblSuccess.Text = "Регистрация прошла успешно! Теперь вы можете войти в систему.";
                            ClearForm();
                        }
                        else
                        {
                            lblError.Text = "Ошибка при регистрации. Попробуйте еще раз.";
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                lblError.Text = "Ошибка базы данных: " + ex.Message;
            }
            catch (Exception ex)
            {
                lblError.Text = "Произошла ошибка: " + ex.Message;
            }
        }

        private void ClearForm()
        {
            txtEmail.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
            txtLastName.Text = "";
            txtFirstName.Text = "";
            txtMiddleName.Text = "";
            txtPassportSeries.Text = "";
            txtPassportNumber.Text = "";
        }
    }
}