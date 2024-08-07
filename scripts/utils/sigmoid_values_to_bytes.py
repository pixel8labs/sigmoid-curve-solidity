# Python script to convert uint32 values to a hex string
values = [
    1040594, 1138435, 1246331, 1365286, 1496401, 1640880, 1800036, 1975301,
    2168234, 2380530, 2614029, 2870720, 3152756, 3462453, 3802304, 4174976,
    4583320, 5030364, 5519315, 6053551, 6636609, 7272169, 7964032, 8716088,
    9532280, 10416555, 11372809, 12404820, 13516172, 14710165, 15989723,
    17357289, 18814711, 20363136, 22002890, 23733379, 25552981, 27458972,
    29447462, 31513358, 33650364, 35851010, 38106724, 40407937, 42744229,
    45104507, 47477208, 49850521, 52212626, 54551923, 56857259, 59118137,
    61324893, 63468845, 65542407, 67539157, 69453880, 71282560, 73022357,
    74671538, 76229406, 77696199, 79072981, 80361535, 81564248, 82683998,
    83724051, 84687966, 85579505, 86402554, 87161059, 87858964, 88500168,
    89088482, 89627600, 90121075, 90572300, 90984502, 91360728, 91703846,
    92016543, 92301328, 92560538, 92796339, 93010741, 93205595, 93382613,
    93543366, 93689299, 93821739, 93941898, 94050889, 94149727, 94239338,
    94320569, 94394190, 94460905, 94521352, 94576114, 94625720, 94670649,
    94711340, 94748189, 94781556, 94811768, 94839122, 94863886, 94886304,
    94906599, 94924969, 94941598, 94956649, 94970272, 94982602, 94993761,
    95003861, 95013001, 95021274, 95028760, 95035534, 95041665, 95047213,
    95052234, 95056778, 95060889, 95064609, 95067976, 95071023, 95073779,
    95076274, 95078531, 95080574, 95082422, 95084094, 95085608, 95086977,
    95088216, 95089337, 95090352, 95091270, 95092101, 95092852, 95093532,
    95094148, 95094705, 95095208, 95095664, 95096077, 95096450, 95096788,
    95097094, 95097370, 95097620, 95097847, 95098052, 95098237, 95098405,
    95098556, 95098694, 95098818, 95098930, 95099032, 95099124, 95099208,
    95099283, 95099351, 95099413, 95099469
]

hex_values = ''.join(f'{value:08x}' for value in values)
print(hex_values)
