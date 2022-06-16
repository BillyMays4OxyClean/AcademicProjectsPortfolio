from main import *

# Small support carrier rocket factory

RocketFactory = Factory(SmallCarrierRocket(), 1740, UserSettings(), True)

CombinedFactory = FactoryChain()

CombinedFactory.add_factory(RocketFactory)

CombinedFactory.consolidate_supporting_factories()

report = CombinedFactory.return_consolidated_factory_report()


save_combined_factory_report = open("Factory Chain Report - Current Factory.txt","w")
n = save_combined_factory_report.write(report)
save_combined_factory_report.close()

os.startfile(os.getcwd()+"\\Factory Chain Report - Current Factory.txt")
