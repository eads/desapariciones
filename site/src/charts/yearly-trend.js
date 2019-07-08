import React from "react"
import { LineChart, Line, CartesianGrid, XAxis, YAxis, ResponsiveContainer } from "recharts"

const YearlyTrendChart = () => {
  const data = [
    {
      name: "Page A", uv: 4000, pv: 2400, amt: 2400,
    },
    {
      name: "Page B", uv: 3000, pv: 1398, amt: 2210,
    },
    {
      name: "Page C", uv: 2000, pv: 9800, amt: 2290,
    },
    {
      name: "Page D", uv: 2780, pv: 3908, amt: 2000,
    },
    {
      name: "Page E", uv: 1890, pv: 4800, amt: 2181,
    },
    {
      name: "Page F", uv: 2390, pv: 3800, amt: 2500,
    },
    {
      name: "Page G", uv: 3490, pv: 4300, amt: 2100,
    },
  ];

  const colors = ["#cc0000", "#00cc00",]


  return (
    <ResponsiveContainer
      aspect={1.5}
    >
      <LineChart
        data={data}
        margin={{
          top: 10, right: 10, left: 30, bottom: 10,
        }}
      >
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="name" />
        <YAxis />
        <Line type="monotone" dataKey="pv" stroke="#8884d8" activeDot={{ r: 8 }} isAnimationActive={false} />
        <Line type="monotone" dataKey="uv" stroke="#82ca9d" isAnimationActive={false} />
      </LineChart>
    </ResponsiveContainer>
  )
}

export default YearlyTrendChart
