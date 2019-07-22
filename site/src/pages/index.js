import React from "react"

import Layout from "../components/layout"
import SEO from "../components/seo"
import Cards from "../components/cards"
import Map from "../components/map"
import ViewportIndicator from "../charts/viewport-indicator"

const IndexPage = () => {
  return (
    <Layout>
      <SEO title="Map" />
      <div className="explorer-pane">
        <ViewportIndicator />
        <Cards />
      </div>
      <div className="map-pane">
        <Map />
      </div>
    </Layout>
  )
}

export default IndexPage
