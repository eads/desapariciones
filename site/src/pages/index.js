import React from "react"
import { graphql } from "gatsby"

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

export const query = graphql`
  query {
    desapariciones {
      views_municipales_summary_ctr {
        disappearance_count
        geom
      }
      processed_areas_geoestadisticas_estatales {
        nom_ent
        cve_ent
        cenapi_by_year {
          year
          count
          cumulative_count
        }
      }
    }
  }
`
