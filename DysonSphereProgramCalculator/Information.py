from main import *

# Factory to produce information matrices using only Mk I logistics

Information = Factory(UniverseMatrix(), 35, UserSettings(), True)

CombinedFactory = FactoryChain(UserSettings())

CombinedFactory.add_factory(Information)

report = CombinedFactory.return_factory_report()

save_combined_factory_report = open("Speedrun.txt","w")
n = save_combined_factory_report.write(report)
save_combined_factory_report.close()

os.startfile(os.getcwd()+"\\Speedrun.txt")