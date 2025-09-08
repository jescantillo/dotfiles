---@diagnostic disable: undefined-global

return {
	s("date", t(os.date("%Y/%m/%d"))),
	s("mail", t("dev@jesuscantillo.com")),
	s("email", t("dev@jesuscantillo.com")),
	s("gh", t("github.com/jescantillo")),
	s("(", { t("("), i(1), t(")") }),
	s("[", { t("["), i(1), t("]") }),
	s("{", { t("{"), i(1), t("}") }),
	s("$", { t("$"), i(1), t("$") }),
}


