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
                      ed_high_school_degree = str_detect(job_description, "high school"),
                      ed_associates_degree = str_detect(job_description, "associate's degree") | 
                                              str_detect(job_description, "associates degree"), 
                      ed_bachelors_degree = str_detect(job_description, "bachelor's degree") | 
                                              str_detect(job_description, "bachelors degree") | 
                                              str_detect(job_description, " bs ") | 
                                              str_detect(job_description, " ba "), 
                      ed_bachelors_of_science = str_detect(job_description, "bachelor's of science") | 
                                                  str_detect(job_description, "bachelors of science") | 
                                                  str_detect(job_description, " bs "),
                      ed_masters_degree = str_detect(job_description, "masters degree") | 
                                            str_detect(job_description, "master's degree"), 
                      ed_masters_of_science = str_detect(job_description, "master's of science") | 
                                                str_detect(job_description, "masters of science"),
                      ed_phd = str_detect(job_description, "phd"), 
                      ed_comp_sci_field = str_detect(job_description, "computer science"), 
                      ed_eng_field = str_detect(job_description, "engineering"),
                      ed_stem = str_detect(job_description, "stem"))

# CREATE FLAGS FOR PROGRAMMING LANGUAGE REQUIREMENTS ----------------------
# This section creates flags for programming language requirements for the job 
# listings imported above.
# If a given programming language is mentioned in the job posting, the 
# relevant column is set to 1.
# I take a pretty broad view of programming language, including flags for 
# Git and Github
job_postings = mutate(job_postings, 
                      programming_java = str_detect(job_description, "java"), 
                      programming_javascript = str_detect(job_description, "javascript"),
                      programming_jquery = str_detect(job_description, "jquery"),
                      programming_j2ee = str_detect(job_description, "j2ee"), 
                      programming_angular = str_detect(job_description, "angular"), 
                      programming_git = str_detect(job_description, "git"), 
                      programming_github = str_detect(job_description, "github"), 
                      programming_swagger = str_detect(job_description, "swagger"), 
                      programming_postman = str_detect(job_description, "postman"), 
                      programming_elastic_search = str_detect(job_description, "elastic_search"), 
                      programming_kinesis = str_detect(job_description, "kinesis"), 
                      programming_lambda = str_detect(job_description, "lambda"), 
                      programming_rds = str_detect(job_description, "rds"), 
                      programming_redshift = str_detect(job_description, "redshift"), 
                      programming_s3 = str_detect(job_description, "s3"), 
                      programming_glacier = str_detect(job_description, "glacier"), 
                      programming_dynamodb = str_detect(job_description, "dynamodb"), 
                      programming_sqs = str_detect(job_description, "sqs"), 
                      programming_sns = str_detect(job_description, "sns"), 
                      programming_elastic_cache = str_detect(job_description, "elastic_cache"), 
                      programming_ec2 = str_detect(job_description, "ec2"), 
                      programming_ecs = str_detect(job_description, "ecs"), 
                      programming_kibana = str_detect(job_description, "kibana"), 
                      programming_spark = str_detect(job_description, "spark"), 
                      programming_hadoop = str_detect(job_description, "hadoop"),
                      programming_aws = str_detect(job_description, "aws"),
                      programming_azure = str_detect(job_description, "azure"), 
                      programming_sql = str_detect(job_description, "sql"), 
                      programming_nosql = str_detect(job_description, "nosql"), 
                      programming_python = str_detect(job_description, "python"), 
                      programming_swift = str_detect(job_description, "swift"), 
                      programming_carthage = str_detect(job_description, "carthage"), 
                      programming_php = str_detect(job_description, "php"), 
                      programming_html = str_detect(job_description, "html"), 
                      programming_html5 = str_detect(job_description, "html5"), 
                      programming_css = str_detect(job_description, "css"), 
                      programming_css3 = str_detect(job_description, "css3"),
                      programming_bootstrap = str_detect(job_description, "bootstrap"), 
                      programming_ajax = str_detect(job_description, "ajax"), 
                      programming_jboss = str_detect(job_description, "jboss"), 
                      programming_oracle_db = str_detect(job_description, "oracle db"),
                      programming_rhapsody = str_detect(job_description, "rhapsody"), 
                      programming_vxworks = str_detect(job_description, "vxworks"), 
                      programming_ejb = str_detect(job_description, "ejb"), 
                      programming_microstrategy = str_detect(job_description, "microstrategy"), 
                      programming_tableau = str_detect(job_description, "tableau"), 
                      programming_arcgis = str_detect(job_description, "arcgis"), 
                      `programming_3-gis` = str_detect(job_description, "3-gis"), 
                      programming_autocad = str_detect(job_description, "autocad"), 
                      programming_visio = str_detect(job_description, "visio"),
                      programming_ruby = str_detect(job_description, "ruby"), 
                      programming_ruby_on_rails = str_detect(job_description, "ruby_on_rails"),
                      `programming_c++` = str_detect(job_description, "c++"),
                      `programming_c#` = str_detect(job_description, "c#"),
                      programming_c = str_detect(job_description, " c,") |                         # This one is tricky...
                                        str_detect(job_description, " c "), 
                      programming_r = str_detect(job_description, " r,") |                         # This one is tricky...
                                        str_detect(job_description, " r "))                       


