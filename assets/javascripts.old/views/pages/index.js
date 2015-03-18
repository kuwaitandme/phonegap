module.exports = {
	"account-manage":    require("./account.manage"),
	"account":           require("./auth.login"),
	"auth-forgot":       require("./auth.login"),
	"auth-login":        require("./auth.login"),
	"auth-signup":       require("./auth.login"),
	"auth-reset":        require("./auth.login"),
	"classified-edit":   require("./classified.edit"),
	"classified-finish": require("./classified.finish"),
	"classified-post":   require("./classified.post"),
	"classified-search": require("./classified.search"),
	"classified-single": require("./classified.single"),
	"landing":           require("./landing")
};