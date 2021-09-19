MSc in Geospatial Technologies/ Master thesis repository
=

[![made-with-javascript](https://img.shields.io/badge/Coded%20with-javascript-21496b.svg?style=flat-square)](https://www.javascript.com/)
[![made-with-latex](https://img.shields.io/badge/Documented%20with-LaTeX-4c9843.svg?style=flat-square)](https://www.latex-project.org/) ![GitHub repo size](https://img.shields.io/github/repo-size/Ponsoda/GEOTECH-master-thesis-vehicle-position?style=flat-square) ![GitHub](https://img.shields.io/github/license/Ponsoda/GEOTECH-master-thesis-vehicle-position?style=flat-square) ![Maintenance](https://img.shields.io/maintenance/yes/2020?style=flat-square)

---

###### Analysis of the effect of bus stops on the bus speed regarding the usage of public bus fleet as probe vehicles

Master thesis of the MSc in Geospatial Technologies between the [Westfälische Wilhelms-Universität Münster](https://www.uni-muenster.de/en/) (Münster, Germany), the [Universitat Jaume I](https://www.uji.es/) (Castellón, Spain) and the [Universidade Nova de Lisboa](https://www.unl.pt/en) (Lisbon, Portugal).

Supervisors: **Dr. Joaquin Huerta** Department of Information Systems at Universitat Jaume I, **Jesús de Diego** Head of Geospatial Department at IDOM Consulting and **Marco Painho** NOVA Information Management School at Universidade Nova de Lisboa.

---

# Abstract

Public bus fleet location data has emerged in the last years as an affordable opportunity
for local governments to monitor the city traffic. However, the speed data
calculated from the location of the public bus fleet tend to be affected by bus stops,
Consequently, the inclination on this field is to discard the speed affected by bus stops
for traffic monitoring. Several approaches have been developed to identify the bus
data affected by bus stops.
In this work, the effect on traffic monitoring of bus location data affected by a
bus stop is tested through a case study in La Castellana, one of the main arteries
of Madrid -the capital city of Spain-, by using data of its public urban transport
company, the Empresa Municipal de Transportes (EMT).
The analysis of the results concludes that the use of public bus fleet location data
affected by bus stops has a bias effect on traffic monitoring. However, it also concludes
that this bias effect is mainly caused by the buses dropping or collecting passengers.
Keywords: probe vehicle, location data, traffic monitoring, public bus fleet


# Code

The repository contains [four JavaScript scripts](https://github.com/Ponsoda/GEOTECH-master-thesis-vehicle-position/tree/master/js)
  * Data collection
  * Speed calculation
  * Secctions assignation
  * Stops assignation
  
Also an [R code](https://github.com/Ponsoda/GEOTECH-master-thesis-vehicle-position/blob/master/TFM_RScript.R) for the data exploration + two shiny applications for visualize the results

*Data collected from https://mobilitylabs.emtmadrid.es/


---

You can find the documment [here](https://run.unl.pt/bitstream/10362/96488/1/TGEO0232.pdf).
