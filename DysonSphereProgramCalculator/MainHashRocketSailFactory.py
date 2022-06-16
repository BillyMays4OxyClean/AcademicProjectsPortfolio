from main import *

# End goal factory for my main world

RocketFactory = Factory(SmallCarrierRocket(), 32500, UserSettings(), True)

CubeFactory = Factory(Hashes(), pow(10,6) * 60, UserSettings(), True)

SailFactory = Factory(SolarSail(), 100000, UserSettings(), True)

CombinedFactory = FactoryChain()

CombinedFactory.add_factory(RocketFactory)
CombinedFactory.add_factory(CubeFactory)
CombinedFactory.add_factory(SailFactory)

CombinedFactory.consolidate_supporting_factories()

report = CombinedFactory.return_consolidated_factory_report()


save_combined_factory_report = open("Factory Chain Report - Rockets Hashes and Sails.txt","w")
n = save_combined_factory_report.write(report)
save_combined_factory_report.close()

os.startfile(os.getcwd()+"\\Factory Chain Report - Rockets Hashes and Sails.txt")