data_dashboard
==============

# Requirements 
* Python>=3.3 and [some packages](https://github.com/alprobit/data_dashboard/blob/master/python-requirements.txt) for it
* CoffeeScript>=1.9
* MySQL>=5.5 (also: e.g. for Debian / Ubuntu ```libmysqlclient-dev``` must be installed)

# How to run
1. MySQL settings  
  1.1. Create user and schema in mysql shell:
   ```sql
  create user 'dashboard'@'localhost' identified by 'dashboard';
  create database dashboard;
  grant all privileges on dashboard.* to dashboard@localhost;
  grant delete, insert on mysql.* to dashboard@localhost;
  ```

  1.2. Compile and install user-defined function ```row_number()```:
  ```bash
  git clone https://github.com/infusion/udf_infusion.git
  cd udf_infusion
  ./configure --enable-functions="row_number"
  make
  sudo make install
  mysql --user=dashboard --password=dashboard dashboard < load.sql
  ```
  
  1.3. Import database (bash):
  ```bash
  bzcat stepic-db-example.mysql.bz2 | mysql --user=dashboard --password=dashboard dashboard
  ```

2. Run django server:
  ```
  cd dashboard_selection
  python3 manage.py runserver
  ```