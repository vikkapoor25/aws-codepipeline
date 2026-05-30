DROP TABLE IF EXISTS arsenal_2025_26_squad;

CREATE TABLE arsenal_2025_26_squad (
    player_id SERIAL PRIMARY KEY,
    squad_number INTEGER UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    display_name VARCHAR(160) NOT NULL,
    position_group VARCHAR(40) NOT NULL,
    primary_position VARCHAR(80),
    nationality VARCHAR(80),
    is_homegrown BOOLEAN DEFAULT FALSE,
    is_academy BOOLEAN DEFAULT FALSE,
    notes TEXT
);

INSERT INTO arsenal_2025_26_squad
    (squad_number, first_name, last_name, display_name, position_group, primary_position, nationality, is_homegrown, is_academy, notes)
VALUES
    (1,  'David',      'Raya',           'David Raya',            'Goalkeeper', 'Goalkeeper',              'Spain',          FALSE, FALSE, NULL),
    (2,  'William',    'Saliba',         'William Saliba',        'Defender',   'Centre-back',             'France',         FALSE, FALSE, NULL),
    (3,  'Cristhian',  'Mosquera',       'Cristhian Mosquera',    'Defender',   'Centre-back',             'Spain',          FALSE, FALSE, 'New signing for 2025/26'),
    (4,  'Ben',        'White',          'Ben White',             'Defender',   'Right-back / Centre-back','England',        TRUE,  FALSE, NULL),
    (5,  'Piero',      'Hincapie',       'Piero Hincapie',        'Defender',   'Centre-back / Left-back', 'Ecuador',        FALSE, FALSE, 'Joined on loan for 2025/26'),
    (6,  'Gabriel',    'Magalhaes',      'Gabriel Magalhaes',     'Defender',   'Centre-back',             'Brazil',         FALSE, FALSE, NULL),
    (7,  'Bukayo',     'Saka',           'Bukayo Saka',           'Forward',    'Right winger',            'England',        TRUE,  TRUE,  NULL),
    (8,  'Martin',     'Odegaard',       'Martin Odegaard',       'Midfielder', 'Attacking midfielder',    'Norway',         FALSE, FALSE, 'Club captain'),
    (9,  'Gabriel',    'Jesus',          'Gabriel Jesus',         'Forward',    'Striker / Forward',       'Brazil',         FALSE, FALSE, NULL),
    (10, 'Eberechi',   'Eze',            'Eberechi Eze',          'Midfielder', 'Attacking midfielder',    'England',        TRUE,  FALSE, 'New signing for 2025/26'),
    (11, 'Gabriel',    'Martinelli',     'Gabriel Martinelli',    'Forward',    'Left winger',             'Brazil',         FALSE, FALSE, NULL),
    (12, 'Jurrien',    'Timber',         'Jurrien Timber',        'Defender',   'Right-back / Centre-back','Netherlands',    FALSE, FALSE, NULL),
    (13, 'Kepa',       'Arrizabalaga',   'Kepa Arrizabalaga',     'Goalkeeper', 'Goalkeeper',              'Spain',          FALSE, FALSE, 'New signing for 2025/26'),
    (14, 'Viktor',     'Gyokeres',       'Viktor Gyokeres',       'Forward',    'Striker',                 'Sweden',         FALSE, FALSE, 'New signing for 2025/26'),
    (15, 'Jakub',      'Kiwior',         'Jakub Kiwior',          'Defender',   'Centre-back / Left-back', 'Poland',         FALSE, FALSE, NULL),
    (16, 'Christian',  'Norgaard',       'Christian Norgaard',    'Midfielder', 'Defensive midfielder',    'Denmark',        FALSE, FALSE, 'New signing for 2025/26'),
    (17, 'Oleksandr',  'Zinchenko',      'Oleksandr Zinchenko',   'Defender',   'Left-back / Midfielder',  'Ukraine',        FALSE, FALSE, NULL),
    (19, 'Leandro',    'Trossard',       'Leandro Trossard',      'Forward',    'Winger / Forward',        'Belgium',        FALSE, FALSE, NULL),
    (20, 'Noni',       'Madueke',        'Noni Madueke',          'Forward',    'Winger',                  'England',        TRUE,  FALSE, 'New signing for 2025/26'),
    (21, 'Fabio',      'Vieira',         'Fabio Vieira',          'Midfielder', 'Attacking midfielder',    'Portugal',       FALSE, FALSE, NULL),
    (22, 'Ethan',      'Nwaneri',        'Ethan Nwaneri',         'Midfielder', 'Attacking midfielder',    'England',        TRUE,  TRUE,  NULL),
    (23, 'Mikel',      'Merino',         'Mikel Merino',          'Midfielder', 'Central midfielder',      'Spain',          FALSE, FALSE, NULL),
    (24, 'Reiss',      'Nelson',         'Reiss Nelson',          'Forward',    'Winger',                  'England',        TRUE,  TRUE,  NULL),
    (28, 'Albert',     'Sambi Lokonga',  'Albert Sambi Lokonga',  'Midfielder', 'Central midfielder',      'Belgium',        FALSE, FALSE, NULL),
    (29, 'Kai',        'Havertz',        'Kai Havertz',           'Forward',    'Forward / Midfielder',    'Germany',        FALSE, FALSE, NULL),
    (31, 'Karl',       'Hein',           'Karl Hein',             'Goalkeeper', 'Goalkeeper',              'Estonia',        FALSE, FALSE, NULL),
    (33, 'Riccardo',   'Calafiori',      'Riccardo Calafiori',    'Defender',   'Left-back / Centre-back', 'Italy',          FALSE, FALSE, NULL),
    (35, 'Tommy',      'Setford',        'Tommy Setford',         'Goalkeeper', 'Goalkeeper',              'England',        TRUE,  FALSE, NULL),
    (36, 'Martin',     'Zubimendi',      'Martin Zubimendi',      'Midfielder', 'Defensive midfielder',    'Spain',          FALSE, FALSE, 'New signing for 2025/26'),
    (41, 'Declan',     'Rice',           'Declan Rice',           'Midfielder', 'Defensive midfielder',    'England',        TRUE,  FALSE, NULL),
    (49, 'Myles',      'Lewis-Skelly',   'Myles Lewis-Skelly',    'Midfielder', 'Midfielder / Left-back',  'England',        TRUE,  TRUE,  NULL),
    (51, 'Alexei',     'Rojas',          'Alexei Rojas',          'Goalkeeper', 'Goalkeeper',              'Colombia',       TRUE,  TRUE,  NULL),
    (78, 'Jack',       'Porter',         'Jack Porter',           'Goalkeeper', 'Goalkeeper',              'England',        TRUE,  TRUE,  NULL);

