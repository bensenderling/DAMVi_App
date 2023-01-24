---
title: 'Data Analysis Management and Visualization Tool for Research Staff'
tags:
  - MATLAB
  - biomechanics
  - processing
  - treatment
  - human movement
  - dynamical systems
  - nonlinear analysis
authors:
  - name: Benjamin Senderling
    orcid: 0000-0003-2502-0553
    equal-contrib: true
    affiliation: 1
  - name: Deepak Kumar
    equal-contrib: false # (This is how you can denote equal contributions between multiple authors)
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
affiliations:
 - name: Department of Physical Therapy and Athletic Training, Sargent College, Boston University, USA
   index: 1
 - name: Boston University School of Medicine, USA
   index: 2
date: 5 January 2023
bibliography: paper.bib
---

# Summary

Research staff often perform myriad tasks that include managing and analyzing project data, while assisting students. This can be a time-consuming task and is especially so in biomechanics with its diverse array of equipment, and the diverse background of students. Biomechanics is the application of math and physics to understand biological motion. Experiments involve equipment to measure motion, acceleration, force, oxygen consumption and others. It is a field with scientists from backgrounds such as the sciences, engineering, healthcare, or education. It is important for them to produce new and meaningful insights, to reproduce prior works and build an understanding of their own. Learning to use research equipment and analyze their data can be an arduous and time-consuming task for new students and the staff assisting them. The Data Analysis, Management and Visualization Application (DAMVi App) is a package that aims to facilitate these efforts by offering a dynamic framework to manage data, perform data processing and analysis, produce figures, and format the results for additional statistical analysis. The package allows new users to develop their own code within a framework that promotes their own learning but handles more nuanced, but time-consuming aspects of data processing. Furthermore, it allows experienced users to better reuse code for repeated and complex analysis methods, which new users can also run while developing their own understanding of the methods.

# Statement of need

DAMVi App is a MATLAB package developed in a biomechanics lab but to meet the needs of research staff, lab managers and technicians. MATLAB is commonly used in this field, but code is often specific to individual groups or experiments with little cross-compatibility. Those scientists may be students with little programming experience, experienced research staff or faculty. DAMVi aims to help research staff facilitate their activities. The package provides a high-level user interface with a dynamic environment. This allows experienced users to develop their own code and all users to make use of other contributions. It can be adapted to make use of lower-level data analysis packages [@NONAN:2021] and can make use of others [@MOVAN:2021] with modifications. Fields like biomechanics make use of varied methods and analyses. As an open-source contribution, DAMVi provides a structured framework for this research to consolidate efforts and increase reproducibility in data analysis.

This package was designed within a biomechanics laboratory with a focus on reusing existing code and providing a tool for medical and physical therapy graduate students, and undergraduate students, to use on their own. It is used by research staff to perform new analyses and compile existing data across old and new projects. Within its framework, complex analysis code can be developed for a particular project and reused for another. The high-level interface aims to allow students with little programming experience to use the same code, promoting independence from research staff. In these ways it could increase the productivity and quality of work from students, staff and faculty.
