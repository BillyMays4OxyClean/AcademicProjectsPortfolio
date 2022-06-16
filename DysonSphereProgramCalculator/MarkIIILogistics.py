from main import *

# Mark III Logistics factories using Mark I factories

usersettings = UserSettings(1,1,1,1,1,1)
usersettings.DefaultAdvancedRecipeSettings["Graphene"] = True
usersettings.DefaultAdvancedRecipeSettings["Energetic Graphite"] = True

Sorterz = Factory(Sorters(3), 90, usersettings, True)

CombinedFactory = FactoryChain(usersettings)
CombinedFactory.add_factory(Sorterz)

report = CombinedFactory.return_factory_report()

report_name = "Factory Chain Report - Mk III Sorters 2"

save_combined_factory_report = open(report_name + ".txt", "w")
n = save_combined_factory_report.write(report)
save_combined_factory_report.close()
os.startfile(os.getcwd() + "\\" + report_name + ".txt")

Beltz = Factory(Belts(3), 135, usersettings, True)
CombinedFactory = FactoryChain(usersettings)
CombinedFactory.add_factory(Beltz)

report = CombinedFactory.return_factory_report()

report_name = "Factory Chain Report - Mk III Belts 2"

save_combined_factory_report = open(report_name + ".txt", "w")
n = save_combined_factory_report.write(report)
save_combined_factory_report.close()
os.startfile(os.getcwd() + "\\" + report_name + ".txt")


Assemblers = Factory(Assembler(3), 11.25, usersettings, True)
CombinedFactory = FactoryChain(usersettings)
CombinedFactory.add_factory(Assemblers)

report = CombinedFactory.return_factory_report()

report_name = "Factory Chain Report - Mk III Assemblers 2"

save_combined_factory_report = open(report_name + ".txt", "w")
n = save_combined_factory_report.write(report)
save_combined_factory_report.close()
os.startfile(os.getcwd() + "\\" + report_name + ".txt")

