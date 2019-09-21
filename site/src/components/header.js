import React from "react"
import { FormattedMessage, Link } from "gatsby-plugin-intl"
import Language from "./language"
import Warning from "./warning"

const Header = () => (
  <header>
    <h1>
      <Link to="/">
        <FormattedMessage id="title" />
      </Link>
    </h1>
    <Warning />
    <Language />
  </header>
)

export default Header
