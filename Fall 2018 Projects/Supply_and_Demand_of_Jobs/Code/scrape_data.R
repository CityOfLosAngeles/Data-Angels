# This script scrapes education and programming language requirements
# from scraped job posting data.

# IMPORT LIBRARIES --------------------------------------------------------
pacman::p_load(readr, dplyr, stringr)

# IMPORT DATA -------------------------------------------------------------
# Make sure to set working directory.
job_postings = read_csv("Monster_LA__Software_Programmer_Scraped_Data_20_03_10_09_2018.csv")

# PRE-PROCESS DATA --------------------------------------------------------
# This section cleans up the data for ease of use.

  # Pre-process data.
  job_postings = select(job_postings, -X1) %>%                     # Remove useless column.
    
                  rename(position = `0`,                           # Rename columns
                         company = `1`, 
                         location = `2`, 
                         job_description = `3`) %>% 
    
                  mutate(position = tolower(position),             # Make fields lowercase.
                         company = tolower(company), 
                         location = tolower(location), 
                         job_description = tolower(job_description)) %>%
    
                  filter(!(position == "error loading" &           # Remove invalid job listings.
                             company == "error loading" & 
                             location == "error loading" & 
                             job_description == "error loading")) %>% 
    
                  filter(is.na(job_description) == F)              # Remove more invalid job listings.
  
# CREATE FLAGS FOR EDUCATIONAL REQUIREMENTS -------------------------------
# This section creates flags for educational requirements for the job 
# listings imported above.
# If a given category is mentioned in the job posting, the relevant column is 
# set to 1.
job_postings = mutate(job_postings, 
                      ed_hs_degree = str_count(job_description, "high school"),
                      ed_associates_degree = str_count(job_description, "associate's") + str_count(job_description, "associates"), 
                      ed_bachelors_degree = str_count(job_description, "bachelor's") + str_count(job_description, "bachelors") + 
                                              str_count(job_description, " bs ") + str_count(job_description, " ba "), 
                      ed_bachelors_of_science = str_count(job_description, "bachelor's of science") + str_count(job_description, "bachelors of science") + 
                                                  str_count(job_description, " bs "),
                      ed_masters_degree = str_count(job_description, "master's") + str_count(job_description, "masters"), 
                      ed_masters_of_science = str_count(job_description, "master's of science") + str_count(job_description, "masters of science"),
                      ed_phd = str_count(job_description, "phd"), 
                      ed_comp_sci_field = str_count(job_description, "computer science"), 
                      ed_eng_field = str_count(job_description, "engineering"),
                      ed_stem_field = str_count(job_description, "stem"), 
                      ed_ds_field = str_count(job_description, "data science"),
                      ed_bootcamp = str_count(job_description, "bootcamp"), 
                      ed_ga = str_count(job_description, "general assembly"))

# CREATE FLAGS FOR PROGRAMMING LANGUAGE REQUIREMENTS ----------------------
# This section creates flags for programming language requirements for the job 
# listings imported above.
# If a given programming language is mentioned in the job posting, the 
# relevant column is set to 1.
# I take a pretty broad view of programming language, including flags for 
# Git and Github
job_postings = mutate(job_postings, 
                      programming_java = str_count(job_description, "java"), 
                      programming_javascript = str_count(job_description, "javascript"),
                      programming_jquery = str_count(job_description, "jquery"),
                      programming_j2ee = str_count(job_description, "j2ee"), 
                      programming_angular = str_count(job_description, "angular"), 
                      programming_git = str_count(job_description, "git"), 
                      programming_github = str_count(job_description, "github"), 
                      programming_swagger = str_count(job_description, "swagger"), 
                      programming_postman = str_count(job_description, "postman"), 
                      programming_elastic_search = str_count(job_description, "elastic_search"), 
                      programming_kinesis = str_count(job_description, "kinesis"), 
                      programming_lambda = str_count(job_description, "lambda"), 
                      programming_rds = str_count(job_description, "rds"), 
                      programming_redshift = str_count(job_description, "redshift"), 
                      programming_s3 = str_count(job_description, "s3"), 
                      programming_glacier = str_count(job_description, "glacier"), 
                      programming_dynamodb = str_count(job_description, "dynamodb"), 
                      programming_sqs = str_count(job_description, "sqs"), 
                      programming_sns = str_count(job_description, "sns"), 
                      programming_elastic_cache = str_count(job_description, "elastic_cache"), 
                      programming_ec2 = str_count(job_description, "ec2"), 
                      programming_ecs = str_count(job_description, "ecs"), 
                      programming_kibana = str_count(job_description, "kibana"), 
                      programming_spark = str_count(job_description, "spark"), 
                      programming_hadoop = str_count(job_description, "hadoop"),
                      programming_aws = str_count(job_description, "aws"),
                      programming_azure = str_count(job_description, "azure"), 
                      programming_sql = str_count(job_description, "sql"), 
                      programming_nosql = str_count(job_description, "nosql"), 
                      programming_python = str_count(job_description, "python"), 
                      programming_swift = str_count(job_description, "swift"), 
                      programming_carthage = str_count(job_description, "carthage"), 
                      programming_php = str_count(job_description, "php"), 
                      programming_html = str_count(job_description, "html"), 
                      programming_html5 = str_count(job_description, "html5"), 
                      programming_css = str_count(job_description, "css"), 
                      programming_css3 = str_count(job_description, "css3"),
                      programming_bootstrap = str_count(job_description, "bootstrap"), 
                      programming_ajax = str_count(job_description, "ajax"), 
                      programming_jboss = str_count(job_description, "jboss"), 
                      programming_oracle_db = str_count(job_description, "oracle db"),
                      programming_rhapsody = str_count(job_description, "rhapsody"), 
                      programming_vxworks = str_count(job_description, "vxworks"), 
                      programming_ejb = str_count(job_description, "ejb"), 
                      programming_microstrategy = str_count(job_description, "microstrategy"), 
                      programming_tableau = str_count(job_description, "tableau"), 
                      programming_arcgis = str_count(job_description, "arcgis"), 
                      `programming_3-gis` = str_count(job_description, "3-gis"), 
                      programming_autocad = str_count(job_description, "autocad"), 
                      programming_visio = str_count(job_description, "visio"),
                      programming_ruby = str_count(job_description, "ruby"), 
                      programming_ruby_on_rails = str_count(job_description, "ruby_on_rails"),
                      `programming_c++` = str_count(job_description, "c\\++"),
                      `programming_c#` = str_count(job_description, "c#"),
                      programming_c = str_count(job_description, " c,") + str_count(job_description, " c "),   # This one is tricky...
                      programming_r = str_count(job_description, " r,") + str_count(job_description, " r "))   # This one is tricky...                     


