# Group 3
!wget "https://datasets.imdbws.com/name.basics.tsv.gz"
!wget "https://datasets.imdbws.com/title.basics.tsv.gz"
!wget "https://datasets.imdbws.com/title.ratings.tsv.gz"
!wget "https://datasets.imdbws.com/title.episode.tsv.gz"
!wget "https://datasets.imdbws.com/title.akas.tsv.gz"
!wget "https://datasets.imdbws.com/title.crew.tsv.gz"
!wget "https://datasets.imdbws.com/title.principals.tsv.gz"

import numpy as np
import pandas as pd
import os
import gzip
import shutil


def Other_titles(file):
    
    out_tsv = file[['titleId','title','region','language','isOriginalTitle']]
    out_tsv.to_csv('Other_Titles.tsv',index=False,na_rep=r'\N',sep='\t')

def Cast_and_Crew(file):
    
    out_tsv = file[['nconst','primaryName','birthYear','deathYear', 'primaryProfession', 'knownForTitles' ]]
    out_tsv['usual_role1'], out_tsv['usual_role2'], out_tsv['usual_role3'] = out_tsv['primaryProfession'].str.split(',', 2).str
    out_tsv['known_for1'], out_tsv['known_for2'], out_tsv['known_for3'], out_tsv['known_for4'] = out_tsv['knownForTitles'].str.split(',', 3).str
    out_tsv = out_tsv[['nconst','primaryName','birthYear','deathYear', 'usual_role1', 'usual_role2', 'usual_role3', 'known_for1', 			'known_for2','known_for3','known_for4']]    
    out_tsv.to_csv('Cast_and_Crew.tsv',index=False,na_rep=r'\N',sep='\t')


def Worked_in(file):
    
    out_tsv = file[['tconst','nconst','category']]
    out_tsv.to_csv('Worked_in.tsv',index=False,na_rep=r'\N',sep='\t')

def Imdb_entities(file):
    
    out_tsv = file[['tconst','titleType','primaryTitle', 'originalTitle', 
                            'isAdult', 'startYear', 'endYear', 'runtimeMinutes', 'genres']]
    out_tsv['Genre1'], out_tsv['Genre2'], out_tsv['Genre2'] = out_tsv['genres'].str.split(',', 2).str
    out_tsv = out_tsv[['tconst','titleType','primaryTitle',
    'originalTitle', 'isAdult', 'startYear', 'endYear', 'runtimeMinutes', 'Genre1', 'Genre2', 'Genre3']]
    
    out_tsv.to_csv('Imdb_entity.tsv',index=False,na_rep=r'\N',sep='\t')

def Characters(file):
    
    out_tsv = file[['tconst','nconst','characters']]
    out_tsv = Had_role.dropna()
    out_tsv['characters'] = out_tsv['characters'].str.replace('[\"\[\]]','',regex=True)
    out_tsv['characters'] = out_tsv['characters'].str.replace('\\','|')
    out_tsv = out_tsv.assign(characters=out_tsv.characters.str.split(',')).explode('characters').reset_index(drop=True)
    out_tsv['characters'] = out_tsv['characters'].str.title()
    out_tsv['characters'] = out_tsv['characters'].str.replace('^ | $','',regex=True)
    out_tsv.drop_duplicates(keep=False,inplace=True)
    out_tsv.to_csv('out_tsv.tsv',index=False,na_rep=r'\N',sep='\t')


def unzip_files(folder):
    print("Unzipping Files")
    unzipped_files = []
    for tsv_file in os.listdir(folder):

        if tsv_file.endswith(".gz"):

            input_path = os.path.join(folder, tsv_file)
            output_path = os.path.join(folder,tsv_file.replace('.gz',''))
            unzipped_files.append(output_path)
            # Unzip current file
            with gzip.open(input_path, 'rb') as f_in:
                with open(output_path, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
    print("All files unzipped")
    return unzipped_files
data_path = '/content/'    #path to zipped files
final_files = unzip_files(data_path)
# name.basics.tsv Cast_and_Crew.tsv
name_basics  = pd.read_csv(os.path.join(data_path,'name.basics.tsv'),
    dtype = {'nconst':'str', 'primaryName':'str', 'birthYear':'Int64',
     'deathYear':'Int64', 'primaryProfession':'str', 'knownForTitles':'str'},
     sep='\t',na_values='\\N')
Imdb_entities(name_basics)
del name_basics

# title.akas.tsv to Other_titles.tsv and Characters.tsv
file = pd.read_csv(os.path.join(data_path,'title.akas.tsv'),
    dtype = {'titleId':'str', 'title':'str', 'region':'str',
    'language':'str', 'types':'str','attributes':'str',
    'isOriginalTitle':'Int64'},
    sep='\t',na_values='\\N',quoting=3)
Other_titles(file)


# title.principals.tsv to Worked_in.tsv, Characters.tsv
title_principals = pd.read_csv(os.path.join(data_path,'title.principals.tsv'),sep='\t',na_values='\\N')
Worked_in(title_principals)
Characters(title_principals)
# Delete title_principals
del title_principals

# title.basics.tsv to Imdb_entities.tsv
title_basics = pd.read_csv(os.path.join(data_path,'title.basics.tsv'),
    dtype = {'tconst':'str', 'titleType':'str', 'primaryTitle':'str',
    'originalTitle':'str', 'isAdult':'int', 'startYear':'Int64',
    'endYear':'Int64', 'runtimeMinutes':'Int64', 'genres':'str'},
    sep='\t',na_values='\\N',quoting=3)
# Make tables
Imdb_entities(title_basics)
del title_basics

