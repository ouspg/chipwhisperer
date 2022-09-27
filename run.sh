#!/bin/bash
cd /home/vagrant/chipwhisperer
echo "running jupyter" > ../cronjupyter.log
export BOKEH_RESOURCES=inline
jupyter notebook --no-browser 2>> ../jupyter.log >> ../jupyter.log
echo "Notebook didn't run or stopped!" >> ../cronjupyter.log