using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MobileOperator
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool isUserLoggedIn = Session["UserId"] != null;
            bool isEmployeeLoggedIn = Session["EmployeeId"] != null;

            // Пользовательский кабинет
            lnkCabinet.Visible = isUserLoggedIn;
            lnkLogin.Visible = !isUserLoggedIn;
            lnkRegister.Visible = !isUserLoggedIn;

            // Администрирование (сотрудники)
            lnkAdmin.Visible = isEmployeeLoggedIn;
            lnkAdminLogin.Visible = !isEmployeeLoggedIn;
        }
    }
}
