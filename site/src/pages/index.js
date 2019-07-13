import React from "react"

import Layout from "../components/layout"
import SEO from "../components/seo"
import Cards from "../components/cards"
import Map from "../components/map"


const IndexPage = () => {
  return (
    <Layout>
      <SEO title="Map" />
      <div className="explorer-pane">
        <Cards />
      </div>
      <div className="map-pane">
        <Map />
      </div>
    </Layout>
  )
}

export default IndexPage
