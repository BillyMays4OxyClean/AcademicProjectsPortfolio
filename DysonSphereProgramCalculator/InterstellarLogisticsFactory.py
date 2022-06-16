from main import *

# Factory for producing interstellar logistics in the early game

usersettings = UserSettings(smelter=1)
usersettings.UseProliferator = False
usersettings.DefaultAdvancedRecipeSettings["Energetic Graphite"] = True
usersettings.DefaultAdvancedRecipeSettings["Graphene"] = True

MainF = FactoryChain(usersettings)

TowerFactory = Factory(OrbitalCollector(), 2, usersettings, True)

MainF.add_factory(TowerFactory)

report = MainF.return_factory_report()

name = "Factory Chain Report - Interstellar Logistics Station 3.txt"

save_combined_factory_report = open(name,"w")
n = save_combined_factory_report.write(report)
save_combined_factory_report.close()

os.startfile(os.getcwd()+"\\"+name)
