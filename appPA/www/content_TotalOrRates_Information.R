#source('identMe.R')
content_TotalOrRates_Information =
  div(
    h5("If '...total' is selected:"),
    indentMe(
      "Yearly EXCESS harm estimates are totalled ",
      br(),
      "for the selected tract or community.",
      br(),
      "If 'communities/tracts' is set to 'communities',",
      br(),
      "this total is the sum",
      br(),
      "across the communities currently selected."
    ),
    h5("If '...adjusted for population' is selected:"),
    indentMe(
      "yearly estimates are rescaled to per 1000 people.",
      br(),
      "If 'communities/tracts' is set to 'communities',",
      br(),
      "the rescaling is done combining  ",
      br(),
      "across the communities currently selected."

    ),
    HTML(paste(collapse=' ',

             '•	<strong> Totals versus adjusted rates</strong> .
<br>
  Totals give a sense of actual people harmed (and sum over tracts when appropriate).
<br>
  Rates allow for comparisons among different regions.
  <br>
  Here "rate" means adjusted for population: rescaled to 1000 people.
<br>
So Totals and Rates are each useful in different ways.
           <br>

      <style>
      body {
        font-family: Georgia, serif;
        max-width: 800px;
        margin: 2rem auto;
        padding: 0 1.5rem;
        line-height: 1.7;
        color: #222;
      }
    table {
      border-collapse: collapse;
      margin: 1rem 0;
      width: 100%;
    }
    th, td {
      border: 1px solid #999;
      padding: 0.5rem 1rem;
      text-align: left;
    }
    th { background-color: #f0f0f0; }
        ul { margin-top: 0.5rem; }
      li { margin-bottom: 0.25rem; }
      </style>
        </head>
        <body>

        <p><strong>Total</strong> = estimate of people harmed</p>
        <p><strong>Adjusted for population</strong> = number of people harmed <strong>per 1,000 residents</strong></p>
        <p><strong>For example:</strong></p>

        <table>
        <thead>
        <tr>
        <th></th>
        <th>Clairton</th>
        <th>Plum Borough</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td><strong>Total Deaths</strong></td>
        <td><strong>13.2</strong></td>
        <td><strong>33.82</strong></td>
        </tr>
        <tr>
        <td>Population</td>
        <td>6,620</td>
        <td>27,195</td>
        </tr>
        <tr>
        <td>Adjusted for Population</td>
        <td>1.99</td>
        <td>1.2</td>
        </tr>
        </tbody>
        </table>

        <p>Plum has more <strong>total deaths</strong> but also has over 4x the population of Clairton. When <strong>adjusted for population</strong>, Clairton has a higher rate of harm (1.99 per 1,000 residents) than Plum Borough (1.2 per 1,000). <strong>Larger communities may have more total deaths simply because more people live there. Looking at the rate helps compare communities fairly.</strong></p>



             <br>
             <strong>NOTE</strong> that the  quantities from the three buttons
             <br> under the graph are not affected by this toggle.
           <br>
             &nbsp;&nbsp;&nbsp;&nbsp;•	<strong>PM2.5 </strong>always shows the <strong>average</strong> over tracts.
           <br>
             &nbsp;&nbsp;&nbsp;&nbsp;•	<strong>Total # of people </strong>  and <strong># babies in the birth cohort</strong> always show the <strong>sum</strong> over tracts.

           <hr>'
    ))
)
