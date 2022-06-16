# Beginnings of the Dyson Sphere Program Production Calculator V1
from math import ceil
from math import floor
import os
from datetime import datetime

########################################
#
#   List of Future Features to Implement
#
########################################

"""
Features to add soon:
    Sub Factory Sorting (Done)
        Sorting according to tier level on the replicator selector (Done)
    ByProduct Reporting (Done)
        List byproducts in reports (Done)
    Total Raw Material Consumption and Production (from advanced recipes) (Done)
    Total Power Required for factory chains (Done)
    Research Hashes to MatrixLab (Done)
        Allow factories to be able to be created to produce hashes
    Better factory naming in reports (Done)
        
    
    Features to add later:
        Add dictionary style preference fetching for facility preference return in the .return_factory_preference(self, recipe) method of the UserSettings class def
        Slightly more parametric formatting for the factory reports
            Automatic alignment of product rates and facility quantities
        Define new class for Tech Tree Upgrades
        Optimal factory dimensions
            As a function of logistics
            Include piler
        Advanced Recipe ByProduct Supply Analysis
            Be able to deduct required raw materials / minute from a factory
            due to production of said raw material as a byproduct from another factory
        Logistics Calculating
            Logistic Stations
                Required Stations
                Warp ships required
                Drones Required
                Power Consumption
                Warpers consumed
            Belts
            Sorters
            Pilers
            Proliferators
        Proliferator Calculations
        Power Plant Calculations
            Power distribution
        Planet Modeling
        Ray Receiver Modeling
            for more accurate power output calculations
        Blue Print
            Interpretation
            Generation
        A more versatile Factory class definition
            Input: either components / min to generate a factory design
                Or number of facilities and their recipe to calculate production
    
    V2 Features:
        GUI
        Trade Studies
        Session saves and exports

    General notes to self:
        The consolidation of factories in the FactoryChain class def scrambles the sub_factory information that is important in the hierarchal sorting of each factory. This needs to be fixed
"""


#################################
#
#   Fundamental Class definitions
#
#################################


class RawMaterial:
    Name = None

    def __init__(self, name="N/A"):
        self.Name = name


class Liquid:
    def __init__(self, stack_size=20):
        self.StackSize = stack_size


class Material:
    def __init__(self, recipe=None, name=None, description=""):
        self.Recipe = recipe
        self.Name = name
        self.Description = description


class Component:
    def __init__(self, recipe=None, name="", description=""):
        self.Recipe = recipe
        self.Name = name
        self.Description = description


class ScienceMatrix(Component):
    def __init__(self, recipe=None, name=None, description=""):
        Component.__init__(self, recipe, name, description)
        self.HashPotential = 900


class Building:
    def __init__(self, recipe=None, name="", description="", peak_workload=0, idle_workload=0):
        self.Recipe = recipe
        self.Name = name
        self.Description = description
        self.WorkConsumption = peak_workload
        self.IdleConsumption = idle_workload


class Production(Building):
    def __init__(self, recipe=None, name="", description="", peak_workload=0, idle_workload=0, production_speed=1.0):
        super().__init__(recipe, name, description, peak_workload, idle_workload)
        self.ProductionSpeed = production_speed
        self.Product = None
        self.Parent = None
        self.Proliferate = False
        self.ProliferationMode = "Extra Products"

    def set_parent(self, par):
        self.Parent = par

    def set_recipe(self, recipe):
        if not isinstance(self, recipe.MadeIn):
            name = recipe.MadeIn().Name if callable(recipe.MadeIn) else recipe.MadeIn.Name
            raise Exception("Unable to Comply: {} must be made in the {}".format(recipe.Name, name))
        self.Product = recipe

    def get_recipe(self):
        if self.Product is None:
            return 0
        else:
            return self.Product

    def return_production(self):
        return (60 * self.ProductionSpeed * self.Product.EndProductQuantity) / self.Product.ProductionTime

    def return_consumption(self):
        if self.get_recipe() is not False:
            consumption_per_minute = []
            for i in self.Product.Ingredients:
                if callable(i[0]):
                    consumption_per_minute.append((i[0](), i[1] * 60 * self.ProductionSpeed / self.Product.ProductionTime))
                else:
                    consumption_per_minute.append((i[0], i[1] * 60 * self.ProductionSpeed / self.Product.ProductionTime))
            return consumption_per_minute
        else:
            raise Exception("Unable to calculate consumption for {}. There is no recipe set.".format(self.Name))

    def proliferate(self, proliferator):
        self.Proliferate = True
        if self.get_recipe() is not 0:
            if self.get_proliferator_mode() == "Extra Products":
                self.Product.EndProductQuantity = self.Recipe.EndProductQuantity * proliferator.ExtraProducts
                self.WorkConsumption = self.WorkConsumption * proliferator.EnergyConsumption
            elif self.get_proliferator_mode() == "Production SpeedUp":
                self.Product.ProductionTime = self.Recipe.ProductionTime / proliferator.ProductionSpeedUp
                self.WorkConsumption = self.WorkConsumption * proliferator.EnergyConsumption

            summ = 0
            for ingredient in self.Product.Ingredients:
                summ += ingredient[1]

            self.Product.Ingredients.append((proliferator, summ / proliferator.NSprays))

        # This method is still under development

    def get_proliferation_status(self):
        return self.Proliferate

    def get_proliferator_mode(self):
        return self.ProliferationMode

    def change_proliferator_mode(self, mode):
        modes = ["Extra Products", "Production Speedup"]

        if mode not in modes:
            raise Exception("Unable to comply: {} is not a valid mode for proliferation".format(mode))

        self.ProliferationMode = mode

    def toggle_proliferator_mode(self):
        if self.ProliferationMode == "Extra Products":
            self.ProliferationMode = "Production Speedup"
        elif self.ProliferationMode == "Production Speedup":
            self.ProliferationMode = "Extra Products"


class PowerPlant(Building):
    def __init__(self, power=None):
        super().__init__()
        self.PowerGeneration = power


class Recipe:
    def __init__(self, ingredients=None, production_time=0.0, end_product_quantity=0.0, name="", desc="",
                 facility=Building, advanced=False, byproducts=None):
        self.Ingredients = ingredients
        self.ProductionTime = production_time
        self.EndProductQuantity = end_product_quantity
        self.Name = name
        self.RecipeDescription = desc
        self.MadeIn = facility
        self.Advanced = advanced
        self.ByProducts = byproducts


class Fuel:
    def __init__(self, energy=None, power_gen_bonus=100, name="", fuel_type=""):
        self.Energy = energy
        self.FuelChamberPowerGen = power_gen_bonus
        self.FuelType = fuel_type
        self.Name = name


class EndProduct:
    def __init__(self, recipe=None, name=None, description=""):
        self.Recipe = recipe
        self.Name = name
        self.Description = description


class DSP:
    def __init__(self, ejection_rate, dsp_component):
        self.EjectionRate = ejection_rate
        self.Component = dsp_component


class Logistics:
    pass


################################
#
#  Units and Scientific Notation
#
################################


class MetricPrefix:
    def __init__(self, exp: int, name, abrv):
        self.Exponent = exp
        self.Value = pow(10, exp)
        self.Name = name
        self.Abbreviation = abrv


class Tera(MetricPrefix):
    def __init__(self):
        MetricPrefix.__init__(self, 12, "Tera", "T")


class Giga(MetricPrefix):
    def __init__(self):
        MetricPrefix.__init__(self, 9, "Giga", "G")


class Mega(MetricPrefix):
    def __init__(self):
        MetricPrefix.__init__(self, 6, "Mega", "M")


class Kilo(MetricPrefix):
    def __init__(self):
        MetricPrefix.__init__(self, 3, "Kilo", "k")


class Milli(MetricPrefix):
    def __init__(self):
        MetricPrefix.__init__(self, -3, "milli", "m")


class Nano(MetricPrefix):
    def __init__(self):
        MetricPrefix.__init__(self, -9, "nano", "n")


class Unit:
    def __init__(self, name="", definition=None, description=""):
        self.Name = name
        self.Definition = definition
        self.Description = description
        self.Value = None
        self.Prefix = None
        self.Abbreviation = ""
        self.Description = ""

    def return_unitless_value(self):
        return self.Value * self.Prefix.Value

    def print_unit_value(self):
        return str(self.Value) + " " + self.Prefix.Abbreviation + self.Abbreviation


class Joule(Unit):
    Description = "A measurement of energy defined by the energy required to move a body one meter with one Newton acting on the body"
    Name = "Joule"
    Abbreviation = "J"

    def __init__(self, prefix, value):
        Unit.__init__(self, self.Name, description=self.Description)
        self.Prefix = prefix
        self.Value = value


class Watt(Unit):
    Description = "A measurement of the rate of energy transfer, defined as one Joule per second."
    Name = "Watt"
    Abbreviation = "W"

    def __init__(self, prefix, value):
        Unit.__init__(self, self.Name, description=self.Description)
        self.Prefix = prefix
        self.Value = value


############################
#
#  Components and Materials
#
############################


class Iron(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Iron ore")


class Copper(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Copper ore")


class Stone(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Stone ore")


class Coal(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Coal")


class Silicon(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Silicon ore")


class Titanium(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Titanium ore")


class Water(RawMaterial, Liquid):
    def __init__(self):
        RawMaterial.__init__(self, "Water")
        Liquid.__init__(self)


class CrudeOil(RawMaterial, Fuel, Liquid):
    def __init__(self):
        RawMaterial.__init__(self, "Crude Oil")
        Fuel.__init__(self, Joule(Mega(), 4.05), 20, "Crude Oil", "Chemical")
        Liquid.__init__(self)


class Hydrogen(RawMaterial, Fuel, Liquid, Material):
    def __init__(self):
        RawMaterial.__init__(self, "Hydrogen")
        Fuel.__init__(self, Joule(Mega(), 9), 100, "Hydrogen", "Chemical")
        Liquid.__init__(self)
        Material.__init__(self, Recipe([(CrudeOil, 1)], 4, 1, "Hydrogen", "", OilRefinery), "Hydrogen", "")


class Deuterium(RawMaterial, Material):
    def __init__(self):
        RawMaterial.__init__(self, "Deuterium")
        Material.__init__(self, Recipe([(Hydrogen, 10)], 2.5, 5, "Deuterium", "", ParticleCollider), "Deuterium")
        self.AdvancedRecipe = Recipe([(Hydrogen, 1)], .017, .01, "Deuterium Fractionation", "", Fractionator)
        #  Recipe([(Hydrogen, 1)], .017, .01, "Deuterium Fractionation", "", Fractionator, True, [(Hydrogen, .99)])


class Antimatter(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(CriticalPhoton, 2)], 2, 2, "Antimatter", "", ParticleCollider, False,
                                       [(Hydrogen, 2)]), "Antimatter")
        self.StackSize = 20
        self.PowerGeneration = Joule(Mega, 600)
        self.MadeIn = ParticleCollider


class Kimberlite(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Kimberlite")


class IronIngots(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Iron, 1)], 1, 1, "Iron Ingots", "", Smelter, False), "Iron Ingots")


class CopperIngots(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Copper, 1)], 1, 1, "Copper Ingots", "", Smelter, False), "Copper Ingots")


class StoneBricks(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Stone, 1)], 1, 1, "Stone bricks", "", Smelter, False), "Stone bricks")


class EnergeticGraphite(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Coal, 2)], 2, 1, "Energetic Graphite", "", Smelter, False), "Energetic Graphite")
        self.AdvancedRecipe = Recipe([(RefinedOil, 1), (Hydrogen, 2)], 4, 1, "X-Ray Cracking", "An advanced recipe for producing energetic graphite", OilRefinery, True, [(Hydrogen, 3)])


class HighPuritySilicon(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Silicon, 2)], 2, 1, "High-Purity Silicon", "", Smelter, False),
                          "High-Purity Silicon")


class TitaniumIngots(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Titanium, 2)], 2, 1, "Titanium Ingots", "", Smelter, False), "Titanium Ingots")


class SulfuricAcid(Material, Liquid, RawMaterial):
    def __init__(self):
        Material.__init__(self,
                          Recipe([(RefinedOil, 6), (Stone, 8), (Water, 4)], 6, 4, "Sulfuric Acid", "", ChemicalPlant))
        RawMaterial.__init__(self, "Sulfuric Acid")


class RefinedOil(Material, Fuel):
    def __init__(self):
        Material.__init__(self, Recipe([(CrudeOil, 2)], 4, 2, "Refined Oil", "", OilRefinery, False, [(Hydrogen, 1)]),
                          30, "Refined Oil")
        Fuel.__init__(self, Joule(Mega, 4.5), 30, "Refined Oil", "Chemical")


class HydrogenFuelRod(EndProduct, Fuel):
    def __init__(self):
        EndProduct.__init__(self, Recipe([(Titanium, 1), (Hydrogen, 10)], 6, 2, "Hydrogen Fuel Rod", "", Assembler))
        Fuel.__init__(self, Joule(Mega, 54), 200, "Hydrogen Fuel Rod")


class DeuteronFuelRod(EndProduct, Fuel):
    def __init__(self):
        EndProduct.__init__(self, Recipe([(TitaniumAlloy, 1), (Deuterium, 20), (SuperMagneticRing, 1)], 12, 2,
                                         "Deuterium Fuel Rod", "", Assembler))
        Fuel.__init__(self, Joule(Mega, 600), 300, "Deuterion Fuel Rod")


class AntimatterFuelRod(EndProduct, Fuel):
    def __init__(self):
        EndProduct.__init__(self,
                            Recipe([(Antimatter, 12), (Hydrogen, 12), (AnnihilationConstraintSphere, 1), (Titanium, 1)],
                                   24, 2, "Anti-matter fuel rod", "", Assembler))
        Fuel.__init__(self, Joule(Giga, 7.2), 500, "Anti-matter fuel rod", "")


class FractalSilicon(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Fractal Silicon")


class Magnet(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Iron, 1)], 1.5, 1, "Magnets", "", Smelter, False), "Magnets")


class MagneticCoil(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(Magnet, 2), (CopperIngots, 1)], 1, 2, "Magnetic Coils", "", Assembler, False),
                           "Magnetic Coils")


class Glass(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Stone, 2)], 2, 1, "Glass", "", Smelter, False), "Glass")


class Diamonds(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(EnergeticGraphite, 1)], 2, 1, "Diamonds", "", Smelter, False), "Diamonds")
        self.AdvancedRecipe = Recipe([(Kimberlite, 1)], 1.5, 2, "Diamonds Advanced Recipe", "", Smelter, True)


class CrystalSilicon(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(HighPuritySilicon, 1)], 2, 1, "Crystal Silicon", "", Smelter),
                          "Crystal Silicon")
        self.AdvancedRecipe = Recipe([(FractalSilicon, 1)], 1.5, 2, "Crystal Silicon",
                                     "Advanced Recipe for producing Crystal Silicon using fractal silicon", Assembler,
                                     True)


class TitaniumAlloy(Material):
    def __init__(self):
        Material.__init__(self,
                          Recipe([(TitaniumIngots, 4), (Steel, 4), (SulfuricAcid, 8)], 12, 4, "Titanium Alloy", "", Smelter),
                          "Titanium Alloy")


class FireIce(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Fire Ice")


class Plastic(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(RefinedOil, 2), (EnergeticGraphite, 1)], 3, 1, "Plastic", "", ChemicalPlant),
                          "Plastic")


class OrganicCrystal(RawMaterial, Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Plastic, 2), (RefinedOil, 1), (Water, 1)], 6, 1, "Organic Crystal", "",
                                       ChemicalPlant), "Organic Crystal")
        RawMaterial.__init__(self, "Organic Crystal")


class Graphene(Material):
    def __init__(self):
        Material.__init__(self,
                          Recipe([(EnergeticGraphite, 3), (SulfuricAcid, 1)], 3, 2, "Graphene", "", ChemicalPlant),
                          "Graphene", "")
        self.AdvancedRecipe = Recipe([(FireIce, 2)], 2, 2, "Graphene Advanced Recipe", "", ChemicalPlant, True,
                                     [(Hydrogen, 1)])


class Thruster(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(Steel, 2), (Copper, 3)], 4, 1, "Thruster", "", Assembler), "Thruster")


class OpticalGratingCrystal(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Optical Grating Crystal")


class Steel(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(IronIngots, 3)], 3, 1, "Steel", "", Smelter, False), "Steel")


class CircuitBoard(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(IronIngots, 2), (CopperIngots, 1)], 1, 2, "Circuit Boards", "", Assembler, False),
                           "Circuit Boards")


class Prism(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(Glass, 3)], 2, 2, "Prism", "", Assembler, False), "Prism")


class Motor(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(IronIngots, 2), (Gears, 1), (MagneticCoil, 1)], 2, 1, "Electric Motor", "",
                                        Assembler), "Electric Motors")


class MicroCrystallineComponent(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(HighPuritySilicon, 2), (CopperIngots, 1)], 2, 1, "Micro-crystalline Component", "", Assembler),
                           "Micro-crystalline Component")


class Proliferator:
    def __init__(self, mk=1):
        if mk == 1:
            self.Name = "Proliferator Mk. I"
            self.NSprays = 12
            self.ExtraProducts = 1.125
            self.ProductionSpeedUp = 1.25
            self.EnergyConsumption = 1.30
            self.Recipe = Recipe([(Coal, 1)], 0.5, 1, "Proliferator Mk. I", "", Assembler)
        elif mk == 2:
            self.Name = "Proliferator Mk. II"
            self.NSprays = 24
            self.ExtraProducts = 1.20
            self.ProductionSpeedUp = 1.50
            self.EnergyConsumption = 1.70
            self.Recipe = Recipe([(Proliferator(1), 2), (Diamonds, 1)], 1, 1, "Proliferator Mk. II", "", Assembler)
        elif mk == 3:
            self.Name = "Proliferator Mk. III"
            self.NSprays = 60
            self.ExtraProducts = 1.25
            self.ProductionSpeedUp = 2.00
            self.EnergyConsumption = 2.50
            self.Recipe = Recipe([(Proliferator(2), 2), (CNT, 1)], 2, 1, "Proliferator Mk. III", "", Assembler)


class CasimirCrystal(Material):
    def __init__(self):
        Material.__init__(self,
                          Recipe([(TitaniumCrystal, 1), (Graphene, 2), (Hydrogen, 12)], 4, 1, "Casimir Crystal", "",
                                 Assembler), "Casimir Crystal")
        self.AdvancedRecipe = Recipe([(OpticalGratingCrystal, 4), (Graphene, 2), (Hydrogen, 12)], 4, 1, "Casimir Crystal", "", Assembler, True)


class StrangeMatter(Material):
    def __init__(self):
        Material.__init__(self,
                          Recipe([(ParticleContainer, 2), (IronIngots, 2), (Deuterium, 10)], 8, 1, "Strange Matter", "",
                                 ParticleCollider), "Strange Matter")


class TitaniumCrystal(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(OrganicCrystal, 1), (TitaniumIngots, 3)], 4, 1, "Titanium Crystal", "", Assembler),
                          "Titanium Crystal")


class CNT(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Graphene, 3), (TitaniumIngots, 1)], 4, 2, "Carbon Nanotubes", "", ChemicalPlant),
                          "Carbon Nanotubes")
        self.AdvancedRecipe = Recipe([(SpiniformStalagmiteCrystal, 2)], 4, 2, "Carbon Nanotubes Advanced Recipe", "",
                                     ChemicalPlant,
                                     True)


class ReinforcedThruster(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(TitaniumAlloy, 5), (Turbine, 5)], 6, 1, "Reinforced Thruster", "", Assembler),
                           "Reinforced Thruster")


class SpiniformStalagmiteCrystal(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Spiniform Stalagmite Crystal")


class Gears(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(IronIngots, 1)], 1, 1, "Gears", "", Assembler), "Gears")


class PlasmaExciter(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(MagneticCoil, 4), (Prism, 2)], 2, 1, "Plasma Exciter", "", Assembler),
                           "Plasma Exciter")


class PhotonCombiner(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(Prism, 2), (CircuitBoard, 1)], 3, 1, "Photon Combiner", "", Assembler),
                           "Photon Combiner")
        self.AdvancedRecipe = Recipe([(OpticalGratingCrystal, 1), (CircuitBoard, 1)], 3, 1,
                                     "Photon Combiner Advanced Recipe", "", Assembler)


class Turbine(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(Motor, 2), (MagneticCoil, 2)], 2, 1, "Electromagnetic Turbine", "", Assembler),
                           "Electromagnetic Turbine")


class Processor(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(CircuitBoard, 2), (MicroCrystallineComponent, 2)], 3, 1, "Processor", "",
                                        Assembler), "Processor")


class AnnihilationConstraintSphere(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(ParticleContainer, 1), (Processor, 1)], 20, 1, "Annihilation Constraint Sphere", "",
                                  Assembler), "Annihilation Constaint Sphere")


class TitaniumGlass(Material):
    def __init__(self):
        Material.__init__(self, Recipe([(Glass, 2), (TitaniumIngots, 2), (Water, 2)], 5, 2, "Titanium Glass", "", Assembler),
                          "Titanium Glass")


class ParticleBroadband(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(CNT, 2), (CrystalSilicon, 2), (Plastic, 1)], 8, 1, "Particle broadband", "",
                                        Assembler), "Particle broadband")


class LogisticsDrone(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(Iron, 5), (Processor, 2), (Thruster, 2)], 4, 1, "Logistics Drone", "", Assembler),
                           "Logistics Drone")


class UnipolarMagnet(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Unipolar Magnet")


class Foundation(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(StoneBricks, 3), (Steel, 1)], 1, 1, "Foundation", "", Assembler),
                           "Foundation")


class CriticalPhoton(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Critical Photon")


class ParticleContainer(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(Turbine, 2), (CopperIngots, 2), (Graphene, 2)], 4, 1, "Particle Container", "",
                                  Assembler), "Particle Container")
        self.AdvancedRecipe = Recipe([(UnipolarMagnet, 10), (CopperIngots, 2)], 4, 1, "Particle Container", "",
                                     Assembler)


class SuperMagneticRing(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(Turbine, 2), (Magnet, 3), (EnergeticGraphite, 1)], 3, 1, "Supermagnetic Ring", "",
                                  Assembler), "Supermagnetic Ring")


class GravitonLens(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(Diamonds, 4), (StrangeMatter, 1)], 6, 1, "Graviton Lens", "", Assembler),
                           "Graviton Lens")


class Warper(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(GravitonLens, 1)], 10, 1, "Warper", "", Assembler), "Warper")
        self.AdvancedRecipe = Recipe([(GravityMatrix, 1)], 10, 8, "Warper Advanced Recipe", "", Assembler, True)


class PlaneFilter(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(CasimirCrystal, 1), (TitaniumGlass, 2)], 12, 1, "Plane Filter", "", Assembler),
                           "Plane Filter")


class QuantumChip(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(Processor, 2), (PlaneFilter, 2)], 6, 1, "Quantum Chip", "", Assembler),
                           "Quantum Chip")


class LogisticsVessel(Component):
    def __init__(self):
        Component.__init__(self, Recipe([(TitaniumAlloy, 10), (Processor, 10), (ReinforcedThruster, 2)], 6, 1,
                                        "Reinforced Thruster", "", Assembler), "Reinforced Thruster")


class Log(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Log")


class ElectromagneticMatrix(ScienceMatrix):
    def __init__(self):
        ScienceMatrix.__init__(self, Recipe([(MagneticCoil, 1), (CircuitBoard, 1)], 3, 1, "Electromagnetic Matrix", "",
                                            MatrixLaboratory), "Electromagnetic Matrix")


class EnergyMatrix(ScienceMatrix):
    def __init__(self):
        ScienceMatrix.__init__(self, Recipe([(EnergeticGraphite, 2), (Hydrogen, 2)], 6, 1, "Energy Matrix", "",
                                            MatrixLaboratory), "Energy Matrix")


class StructureMatrix(ScienceMatrix):
    def __init__(self):
        ScienceMatrix.__init__(self, Recipe([(Diamonds, 1), (TitaniumCrystal, 1)], 8, 1, "Structure Matrix", "",
                                            MatrixLaboratory), "Structure Matrix")


class InformationMatrix(ScienceMatrix):
    def __init__(self):
        ScienceMatrix.__init__(self, Recipe([(Processor, 2), (ParticleBroadband, 1)], 10, 1, "Information Matrix", "",
                                            MatrixLaboratory), "Information Matrix")


class GravityMatrix(ScienceMatrix):
    def __init__(self):
        ScienceMatrix.__init__(self, Recipe([(GravitonLens, 1), (QuantumChip, 1)], 24, 2, "Gravity Matrix", "",
                                            MatrixLaboratory), "Gravity Matrix")


class UniverseMatrix(ScienceMatrix):
    def __init__(self):
        ScienceMatrix.__init__(self, Recipe(
            [(ElectromagneticMatrix, 1), (EnergyMatrix, 1), (StructureMatrix, 1), (InformationMatrix, 1),
             (GravityMatrix, 1), (Antimatter, 1)], 15, 1, "Universe Matrix", "", MatrixLaboratory), "Universe Matrix")


class Hashes:
    def __init__(self):
        self.Recipe = Recipe([(UniverseMatrix, 1)], 30, 350, "Hashes",
                             "A special recipe that is only valid for the Matrix Laboratory", MatrixLaboratory)
        self.Name = "Hashes"


class SolarSail(EndProduct):
    def __init__(self):
        EndProduct.__init__(self, Recipe([(Graphene, 1), (PhotonCombiner, 1)], 4, 2, "Solar Sail", "", Assembler),
                            "Solar Sail")


class FrameMaterial(Material):
    def __init__(self):
        Material.__init__(self,
                          Recipe([(CNT, 4), (TitaniumAlloy, 1), (HighPuritySilicon, 1)], 6, 1, "Frame Material", "",
                                 Assembler), "Frame Material")


class DysonSphereComponent(Component):
    def __init__(self):
        Component.__init__(self,
                           Recipe([(FrameMaterial, 3), (SolarSail, 3), (Processor, 3)], 8, 1, "Dyson Sphere Component",
                                  "", Assembler), "Dyson Sphere Component")


class SmallCarrierRocket(EndProduct):
    def __init__(self):
        EndProduct.__init__(self, Recipe([(DysonSphereComponent, 2), (DeuteronFuelRod, 4), (QuantumChip, 2)], 6, 1,
                                         "Small Carrier Rocket", "", Assembler), "Small Carrier Rocket")


class PlantFuel(RawMaterial):
    def __init__(self):
        RawMaterial.__init__(self, "Plant Fuel")


#####################################
#
#  Buildings and Production Facilities
#
#####################################

class WindTurbine(PowerPlant):
    def __init__(self):
        Building.__init__(self,
                          Recipe([(IronIngots, 6), (Gears, 1), (MagneticCoil, 3)], 4, 1, "Wind Turbine", "", Assembler),
                          "Wind Turbine")
        PowerPlant.__init__(self, Watt(Kilo, 300))


class ThermalPowerPlant(PowerPlant):
    def __init__(self):
        Building.__init__(self, Recipe([(IronIngots, 10), (StoneBricks, 4), (Gears, 4), (MagneticCoil, 4)], 5, 1,
                                       "Thermal Power Plant", "", Assembler), "Thermnal Power Plant")
        PowerPlant.__init__(self, Watt(Mega, 2.16))


class SolarPanel(PowerPlant):
    def __init__(self):
        Building.__init__(self,
                          Recipe([(CopperIngots, 10), (HighPuritySilicon, 10), (CircuitBoard, 5)], 6, 1, "Solar Panel",
                                 "", Assembler), "Solar Panel")
        PowerPlant.__init__(self, Watt(Kilo, 360))


class GeothermalPowerPlant(PowerPlant):
    def __init__(self):
        Building.__init__(self,
                          Recipe([(Steel, 15), (CopperIngots, 20), (PhotonCombiner, 4), (SuperMagneticRing, 1)], 6, 1,
                                 "Geothermal Power Plant", "", Assembler), "Geothermal Power Plant", idle_workload=4500)
        PowerPlant.__init__(self, Watt(Kilo, 90))


class MinifusionPowerPlant(PowerPlant):
    def __init__(self):
        Building.__init__(self, Recipe([(TitaniumAlloy, 12), (SuperMagneticRing, 10), (CNT, 8), (Processor, 4)], 10, 1,
                                       "Minifusion Power Plant", "", Assembler), "Minifusion Power Plant")
        PowerPlant.__init__(self, Watt(Mega, 15))


class EnergyExchanger(Production):
    def __init__(self):
        super().__init__(Recipe([(TitaniumAlloy, 40), (Steel, 40), (Processor, 40), (ParticleContainer, 8)], 15, 1, "Energy Exchanger", "", Assembler), "Energy Exchanger", peak_workload=45000000)
        # PowerPlant.__init__(self, Watt(Mega, 45))
        self.Mode = "Idle"

    def change_mode(self, mode):
        if mode == str.lower("charge mode"):
            self.Mode = "Charge Mode"
        elif mode == str.lower("idle"):
            self.Mode = "Idle"
        elif mode == str.lower("discharge mode"):
            self.Mode = "Discharge Mode"

    def get_mode(self):
        return self.Mode

    def proliferate(self, proliferator):
        pass


class RayReceiver(PowerPlant):
    def __init__(self):
        Building.__init__(self, Recipe(
            [(Steel, 20), (HighPuritySilicon, 20), (PhotonCombiner, 10), (Processor, 5), (SuperMagneticRing, 20)], 8, 1,
            "Ray Receiver", "", Assembler), "Ray Receiver")
        PowerPlant.__init__(self, Watt(Mega, 15))
        self.Mode = "Power Generation"
        self.ConsumingGravitonLens = False

    def switch_mode(self, mode):
        if not mode == "Power Generation" or not mode == "Photon Generation":
            raise Exception("Ray Receiver mode must either be 'Power Generation' or 'Photon Generation'")
        self.Mode = mode

    def calculate_power_output(self, planet=None, star=None):
        print("This feature is still under development")


class ArtificialStar(PowerPlant):
    def __init__(self):
        Building.__init__(self, Recipe(
            [(Titanium, 20), (FrameMaterial, 20), (AnnihilationConstraintSphere, 10), (QuantumChip, 10)], 30, 1,
            "Artificial Star", "", Assembler), "Artificial Star")
        PowerPlant.__init__(self, Watt(Mega, 70))


class OilRefinery(Production):
    def __init__(self):
        super().__init__(Recipe([(Steel, 10), (StoneBricks, 10), (CircuitBoard, 6), (PlasmaExciter, 6)], 6, 1, "Oil Refinery", "", Assembler), "Oil Refinery", "", 960000, 24000, 1)


class ParticleCollider(Production):
    def __init__(self):
        super().__init__(Recipe(
            [(TitaniumAlloy, 20), (FrameMaterial, 20), (SuperMagneticRing, 50), (Graphene, 10), (Processor, 8)], 15, 1,
            "Miniature Particle Collider", "", Assembler), "Miniature Particle Collider", peak_workload=12000000,
                          idle_workload=120000, production_speed=1)



class EMRailEjector(Building, DSP):
    def __init__(self):
        Building.__init__(self, Recipe([(Steel, 20), (Gears, 20), (Processor, 5), (SuperMagneticRing, 10)], 6, 1,
                                       "EM-Rail Ejector", "", Assembler), "EM-Rail Ejector", peak_workload=1200000,
                          idle_workload=60000)
        DSP.__init__(self, SolarSail, 20)


class VerticalLaunchingSilo(Building, DSP):
    def __init__(self):
        Building.__init__(self,
                          Recipe([(TitaniumAlloy, 80), (FrameMaterial, 30), (GravitonLens, 20), (QuantumChip, 10)], 30,
                                 1, "Vertical Launcher Silo", "", Assembler), "Vertical Launcher Silo",
                          peak_workload=18000000, idle_workload=60000)
        DSP.__init__(self, SmallCarrierRocket, 5)


class SprayCoater(Building):
    def __init__(self):
        Building.__init__(self,
                          Recipe([(Steel, 4), (PlasmaExciter, 2), (CircuitBoard, 2), (MicroCrystallineComponent, 2)], 3,
                                 1, "Spray Coater", "", Assembler), "Spray Coater", peak_workload=90000,
                          idle_workload=4500)


class Fractionator(Production):
    def __init__(self):
        Production.__init__(self,Recipe([(Steel, 8), (StoneBricks, 4), (Glass, 4), (Processor, 1)], 3, 1, "Fractionator", "", Assembler), "Fractionator", peak_workload=720000, idle_workload=18000)

    def proliferate(self, proliferator):
        pass


class ChemicalPlant(Production):
    def __init__(self):
        super().__init__(Recipe([(Steel, 8), (StoneBricks, 8), (Glass, 8), (CircuitBoard, 2)], 5, 1, "Chemical Plant",
                                "", Assembler), "Chemical Plant", peak_workload=720000, idle_workload=24000, production_speed=1)


class PlanetaryLogistics(Building):
    def __init__(self):
        super().__init__(Recipe([(Steel, 40), (TitaniumIngots, 40), (ParticleContainer, 20), (Processor, 40)], 20, 1,
                                "Planetary Logistics Station", "", Assembler), "Planetary Logistics Station")


class InterstellarLogistics(Building):
    def __init__(self):
        super().__init__(Recipe([(PlanetaryLogistics, 1), (TitaniumAlloy, 40), (ParticleContainer, 20)], 30, 1, "Interstellar Logistics Station", "", Assembler), "Interstellar Logistics Station")


class Accumulator(Building):
    def __init__(self):
        super().__init__(Recipe([(IronIngots, 6), (SuperMagneticRing, 1), (CrystalSilicon, 6)], 5, 1, "Accumulator", "", Assembler), "Accumulator")


class FullAccumulator(Building):
    def __init__(self):
        super().__init__(Recipe([(Accumulator, 1)], 6, 1, "Full Accumulator", "", EnergyExchanger), "Full Accumulator")


class OrbitalCollector(Building):
    def __init__(self):
        super().__init__(Recipe([(InterstellarLogistics, 1), (SuperMagneticRing, 50), (ReinforcedThruster, 20), (FullAccumulator, 20)], 30, 1, "Orbital Collector", "", Assembler), "Orbital Collector")


class MatrixLaboratory(Production):
    def __init__(self, research_level=1, building_stack=1):
        super().__init__(Recipe([(IronIngots, 8), (Glass, 4), (CircuitBoard, 4), (MagneticCoil, 4)], 3, 1, "Matrix Laboratory", "", Assembler), "Matrix Laboratory", peak_workload=480000, idle_workload=12000, production_speed=1)
        self.HashRate = 60 * research_level


class Smelter(Production):
    def __init__(self, mk=1):
        if mk == 1:
            super().__init__(Recipe([(IronIngots, 4), (StoneBricks, 2), (CircuitBoard, 4), (MagneticCoil, 2)], 3, 1, "Arc Smelter", "", Assembler), "Arc Smelter",  peak_workload=360000, idle_workload=12000, production_speed=1)
        elif mk == 2:
            super().__init__(Recipe([(Smelter(1), 1), (FrameMaterial, 5), (PlaneFilter, 4), (UnipolarMagnet, 15)], 5, 1, "Plane Smelter", "", Assembler), "Plane Smelter", peak_workload=1440000, idle_workload=48000, production_speed=2)
        self.Mk = mk


class Assembler(Production):
    def __init__(self, mk=1):
        if mk == 3:
            super().__init__(Recipe([(Assembler(2), 1), (ParticleBroadband, 8), (QuantumChip, 2)], 4, 1, "Assembler Mk. III", "", Assembler), "Assembler Mk. III", peak_workload=1080000, idle_workload=24000, production_speed=1.5)
        elif mk == 2:
            super().__init__(Recipe([(Assembler(1), 1), (Graphene, 8), (Processor, 4)], 3, 1, "Assembler Mk. II", "", Assembler), "Assembler Mk. II", peak_workload=540000, idle_workload=18000, production_speed=1)
        elif mk == 1:
            super().__init__(Recipe([(IronIngots, 4), (Gears, 8), (CircuitBoard, 4)], 2, 1, "Assembler Mk. I", "", Assembler), "Assembler Mk. I", peak_workload=270000, idle_workload=12000, production_speed=0.75)
        self.Mk = mk


class Belts(Building, Logistics):
    def __init__(self, mk=1):
        if mk == 1:
            Building.__init__(self, Recipe([(IronIngots, 2), (Gears, 1)], 1, 3, "Belt Mk. I", "", Assembler),
                              "Belt Mk. I")
            self.Speed = 6
            self.Mk = mk
        elif mk == 2:
            Building.__init__(self, Recipe([(Belts(1), 3), (Turbine, 1)], 1, 3, "Belt Mk. II", "", Assembler),
                              "Belt Mk. II")
            self.Speed = 12
            self.Mk = mk
        elif mk == 3:
            Building.__init__(self,
                              Recipe([(Belts(2), 3), (SuperMagneticRing, 1), (Graphene, 1)], 1, 3, "Belt Mk. III", "",
                                     Assembler), "Belt Mk. III")
            self.Speed = 30
            self.Mk = mk


class Sorters(Building, Logistics):
    def __init__(self, mk=1):
        if mk == 1:
            Building.__init__(self, Recipe([(IronIngots, 1), (CircuitBoard, 1)], 1, 1, "Sorter Mk. I", "", Assembler),
                              "Sorter Mk. I", peak_workload=18000, idle_workload=9000)
            self.Speed = 1.5
        elif mk == 2:
            Building.__init__(self, Recipe([(Sorters(1), 2), (Motor, 1)], 1, 2, "Sorter Mk. II", "", Assembler),
                              "Sorter Mk. II", peak_workload=36000, idle_workload=9000)
            self.Speed = 3.0
        elif mk == 3:
            Building.__init__(self, Recipe([(Sorters(2), 2), (Turbine, 1)], 1, 2, "Sorter Mk. III", "", Assembler),
                              "Sorter Mk. III", peak_workload=72000, idle_workload=9000)
            self.Speed = 6.0


class UserSettings:
    DefaultSorting = {

        Iron().Name: 1,
        Copper().Name: 1,
        Stone().Name: 1,
        Coal().Name: 1,
        Silicon().Name: 1,
        Titanium().Name: 1,
        Water().Name: 1,
        CrudeOil().Name: 1,
        Hydrogen().Name: 1,
        Deuterium().Name: 1,
        Antimatter().Name: 1,
        Kimberlite().Name: 1,

        IronIngots().Name: 2,
        CopperIngots().Name: 2,
        StoneBricks().Name: 2,
        EnergeticGraphite().Name: 2,
        HighPuritySilicon().Name: 2,
        TitaniumIngots().Name: 2,
        SulfuricAcid().Name: 2,
        RefinedOil().Name: 2,
        HydrogenFuelRod().Name: 2,
        DeuteronFuelRod().Name: 2,
        AntimatterFuelRod().Name: 2,
        FractalSilicon().Name: 2,

        Magnet().Name: 3,
        MagneticCoil().Name: 3,
        Glass().Name: 3,
        Diamonds().Name: 3,
        CrystalSilicon().Name: 3,
        TitaniumAlloy().Name: 3,
        FireIce().Name: 3,
        Plastic().Name: 3,
        OrganicCrystal().Name: 3,
        Graphene().Name: 3,
        Thruster().Name: 3,
        OpticalGratingCrystal().Name: 3,

        Steel().Name: 4,
        CircuitBoard().Name: 4,
        Prism().Name: 4,
        Motor().Name: 4,
        MicroCrystallineComponent().Name: 4,
        Proliferator(1).Name: 4,
        CasimirCrystal().Name: 4,
        StrangeMatter().Name: 4,
        TitaniumCrystal().Name: 4,
        CNT().Name: 4,
        ReinforcedThruster().Name: 4,
        SpiniformStalagmiteCrystal().Name: 4,

        Gears().Name: 5,
        PlasmaExciter().Name: 5,
        PhotonCombiner().Name: 5,
        Turbine().Name: 5,
        Processor().Name: 5,
        Proliferator(2).Name: 5,
        AnnihilationConstraintSphere().Name: 5,
        TitaniumGlass().Name: 5,
        ParticleBroadband().Name: 5,
        LogisticsDrone().Name: 5,
        UnipolarMagnet().Name: 5,

        Foundation().Name: 6,
        CriticalPhoton().Name: 6,
        ParticleContainer().Name: 6,
        SuperMagneticRing().Name: 6,
        GravitonLens().Name: 6,
        Proliferator(3).Name: 6,
        Warper().Name: 6,
        PlaneFilter().Name: 6,
        QuantumChip().Name: 6,
        LogisticsVessel().Name: 6,
        Log().Name: 6,

        ElectromagneticMatrix().Name: 7,
        EnergyMatrix().Name: 7,
        StructureMatrix().Name: 7,
        InformationMatrix().Name: 7,
        GravityMatrix().Name: 7,
        UniverseMatrix().Name: 7,
        Hashes().Name: 7,
        SolarSail().Name: 7,
        FrameMaterial().Name: 7,
        DysonSphereComponent().Name: 7,
        SmallCarrierRocket().Name: 7,
        PlantFuel().Name: 7,

    }

    DefaultBuildingSorting = {

        WindTurbine().Name: 1,
        ThermalPowerPlant().Name: 1,
        SolarPanel().Name: 1,
        Accumulator().Name: 1,
        FullAccumulator().Name: 1,
        GeothermalPowerPlant().Name: 1,
        MinifusionPowerPlant().Name: 1,
        EnergyExchanger().Name: 1,
        RayReceiver().Name: 1,
        ArtificialStar().Name: 1,

        Belts(1).Name: 2,
        Belts(2).Name: 2,
        Belts(3).Name: 2,
        PlanetaryLogistics().Name: 2,
        InterstellarLogistics().Name: 2,
        OrbitalCollector().Name: 2,

        Sorters(1).Name: 3,
        Sorters(2).Name: 3,
        Sorters(3).Name: 3,
        Fractionator().Name: 3,

        OilRefinery().Name: 3,
        ParticleCollider().Name: 3,
        EMRailEjector().Name: 3,
        VerticalLaunchingSilo().Name: 3,

        Assembler(1).Name: 4,
        Assembler(2).Name: 4,
        Assembler(3).Name: 4,
        Smelter(1).Name: 4,
        Smelter(2).Name: 4,
        SprayCoater().Name: 4,
        ChemicalPlant().Name: 4,
        MatrixLaboratory().Name: 4

    }

    Research_Tech_Cost = {

        "Hash to Cubes Ratio": 900

    }

    TechTree_Upgrades = {

        "Research": 10,
        "Building Height": 15

    }

    DefaultRawMaterialSettings = {
        # Serves as a list of raw materials that are capable of being either produced or mined.
        # 'True' Signifying that the resource is to be produced in a factory
        "Sulfuric Acid": True,
        "Organic Crystal": True,
        "Hydrogen": False,
        "Deuterium": True

    }

    DefaultAdvancedRecipeSettings = {
        "Crystal Silicon": False,
        "Diamonds": False,
        "Graphene": False,
        "Carbon Nanotubes": False,
        "Casimir Crystal": False,
        "Particle Container": False,
        "Warper": True,
        "Photon Combiner": False,
        "Energetic Graphite": False,  # This will switch between Smelting coal and X-Ray cracking
        "Deuterium": True
    }



    def __init__(self, belts=3, sorters=3, assembler=3, smelter=2, proliferator=3, piler_stack=4):
        self.Belts = belts
        self.Sorters = sorters
        self.Factories = [assembler, smelter]
        self.Assembler = assembler
        self.Smelter = smelter
        self.Proliferator = proliferator
        self.UseProliferator = True
        self.PilerStack = piler_stack
        self.FractionatorLogistics = [3, 1]
        self.PowerPlantPreferences = [MinifusionPowerPlant, DeuteronFuelRod]
        self.GeneratePowerPlant = True


    def set_research_cost(self, cost):
        self.Research_Tech_Cost["Hash to Cubes Ratio"] = cost

    def return_tier(self, component):
        if isinstance(component, Factory):
            component = component.Product
        if not isinstance(component, Building):
            if component.Name in self.DefaultSorting:
                return self.DefaultSorting[component.Name]
        elif isinstance(component, Building):
            if component.Name in self.DefaultBuildingSorting:
                return self.DefaultBuildingSorting[component.Name]

        raise Exception("Could not determine tier for {}".format(component.Name))

    def return_power_plant_preferences(self):
        return self.PowerPlantPreferences

    def edit_power_plant_preferences(self, plant, fuel):
        if not issubclass(plant, PowerPlant):
            raise Exception("{} must be a subclass of PowerPlant".format(plant().Name))
        if not issubclass(fuel, Fuel):
            raise Exception("{} must be a subclass of Fuel".format(fuel().Name))
        self.PowerPlantPreferences = [plant, fuel]

    def return_factory_preference(self, recipe):
        if issubclass(recipe.MadeIn, Assembler):
            return Assembler(self.Assembler)
        elif issubclass(recipe.MadeIn, Smelter):
            return Smelter(self.Smelter)
        elif issubclass(recipe.MadeIn, MatrixLaboratory) and recipe.Name == "Hashes":
            return MatrixLaboratory(self.TechTree_Upgrades["Research"], self.TechTree_Upgrades["Building Height"])
        else:
            return recipe.MadeIn()

    #        raise Exception("Could not determine factory preference to produce {}".format(recipe.Name))

    def return_recipe_preference(self, component):
        if component.Name == "Hashes":
            corrected_recipe = Recipe([(UniverseMatrix, 1)], self.Research_Tech_Cost["Hash to Cubes Ratio"] / (
                        60 * self.TechTree_Upgrades["Research"]), self.Research_Tech_Cost["Hash to Cubes Ratio"],
                                      "Hashes", "", MatrixLaboratory)
            return corrected_recipe
        elif component.Name == "Deuterium":
            belt_speed = Belts(self.FractionatorLogistics[0]).Speed
            piler_stack = self.FractionatorLogistics[1]
            flow_rate = belt_speed * piler_stack
            production_time = 100/flow_rate
            corrected_recipe = Recipe([(Hydrogen, 1)], production_time, 1, "Deuterium", "", Fractionator)
            return corrected_recipe

        if hasattr(component, "AdvancedRecipe"):
            for key in self.DefaultAdvancedRecipeSettings:
                if key == component.Name:
                    if self.DefaultAdvancedRecipeSettings[key]:
                        return component.AdvancedRecipe
                    else:
                        return component.Recipe
        else:
            return component.Recipe
        raise Exception("Could not determine recipe preference for {}".format(component.Name))

    def return_proliferator(self):
        return Proliferator(self.Proliferator)

    def return_piler_stack(self):
        return self.PilerStack

    def return_belts(self):
        return Belts(self.Belts)

    def return_sorters(self):
        return Sorters(self.Sorters)


class PowerFacility:
    def __init__(self, usersettings=UserSettings(), watts=10000, facility=ThermalPowerPlant(), fuel=HydrogenFuelRod(), pf=1.05, include_jump_start=False):
        power_demand = watts * pf
        nFacilities = ceil(power_demand/facility.PowerGeneration)
        power_production_required = facility.PowerGeneration * nFacilities
        fuel_consumption_per_min = power_production_required / fuel.Energy * 60
        fuel_plant = Factory(fuel, fuel_consumption_per_min, usersettings, True)

        corrected_power_demand = fuel_plant.FullPowerConsumption + power_production_required * pf
        nFacilities_corrected = ceil(corrected_power_demand/facility.PowerGeneration)
        power_production_corrected = facility.PowerGeneration * nFacilities_corrected
        fuel_consumption_per_min_corrected = power_production_corrected / fuel.Energy * 60
        fuel_plant_corrected = Factory(fuel, fuel_consumption_per_min_corrected, usersettings, True)
        s = "Power Plant:\n\n"
        s += "Production:\n"
        s += "\t" + return_prefix_and_val(corrected_power_demand) + "W\n"
        s += "Consumption:\n"
        s += "\t" + "{:,.2f}".format(fuel_consumption_per_min_corrected) + " " + fuel.Name + "s / min\n"
        s += "Required Facilities:\n"
        s += "\t" + "{:,.2f}".format(nFacilities_corrected) + facility.Name + "s required"

        self.FuelPlant = fuel_plant_corrected








class Factory:
    def __init__(self, component, production_per_minute, usersettings, calculate_sub_factories=False, parent=None, tag=""):
        self.UserSettings = usersettings
        if parent:
            self.Parent = parent

        if tag != "":
            self.FactoryTag = tag

        print('Setting up factory for {} to produce: {} / min'.format(component.Name, production_per_minute))
        if not getattr(component, "Name"):
            raise Exception("{} does not have a name".format(component.Recipe.Name))
        self.Name = component.Name
        self.Product = component
        self.Facility = usersettings.return_factory_preference(usersettings.return_recipe_preference(component))
        self.Facility.set_recipe(usersettings.return_recipe_preference(component))
        self.Facility.set_parent(self)
        # if not isinstance(component, Proliferator):
        # self.Facility.proliferate(usersettings.return_proliferator())
        self.SubFactories = []
        self.ProductionGoal = production_per_minute
        self.numOfFacilities = self.calculate_number_of_facilities()
        self.Production = self.calculate_production()
        self.ByProducts = self.calculate_by_products()
        self.Consumption = self.calculate_consumption()
        self.WorkConsumption = self.calculate_work_consumption()
        self.IdleConsumption = self.calculate_idle_consumption()
        self.MaxFactoryEffectiveWidth = self.return_maximum_effective_width(usersettings.return_piler_stack(),usersettings.return_belts())
        self.FullPowerConsumption = [self.WorkConsumption, self.IdleConsumption]
        # self.FactoryCalculatedLength = self.return_calculated_length()
        if calculate_sub_factories:
            for key, value in self.Consumption:
                if not isinstance(key, RawMaterial):
                    if isinstance(component, Proliferator) and isinstance(key, Proliferator):
                        new_fact = Factory(key, value, usersettings, False, self)
                        self.FullPowerConsumption[0] += new_fact.FullPowerConsumption[0]
                        self.FullPowerConsumption[1] += new_fact.FullPowerConsumption[1]
                        self.SubFactories.append(new_fact)
                    else:
                        new_fact = Factory(key, value, usersettings, calculate_sub_factories, self)
                        self.FullPowerConsumption[0] += new_fact.FullPowerConsumption[0]
                        self.FullPowerConsumption[1] += new_fact.FullPowerConsumption[1]
                        self.SubFactories.append(new_fact)
                else:
                    if key.Name in usersettings.DefaultRawMaterialSettings:
                        if usersettings.DefaultRawMaterialSettings[key.Name]:
                            new_fact = Factory(key, value, usersettings, calculate_sub_factories, self)
                            self.FullPowerConsumption[0] += new_fact.FullPowerConsumption[0]
                            self.FullPowerConsumption[1] += new_fact.FullPowerConsumption[1]
                            self.SubFactories.append(new_fact)

        self.FactoryReport = self.return_report()

    # def add_power_factory(self, factory):
    # This feature is still in development

    def assign_factory_tag(self, tag=""):
        self.FactoryTag = tag

    def assign_parent(self, parent):
        self.Parent = parent

    def open_report(self):

        # datetime object containing current date and time
        now = datetime.now()

        # dd/mm/YY H:M:S
        dt_string = now.strftime("%d-%m-%Y %H-%M-%S")

        report_name = self.Name + " " + dt_string

        save_combined_factory_report = open(report_name + ".txt", "w")
        n = save_combined_factory_report.write(self.FactoryReport)
        save_combined_factory_report.close()
        os.startfile(os.getcwd() + "\\" + report_name + ".txt")

    def return_maximum_effective_width(self, nStacks, belts):
        itemsPerMinute = nStacks * belts.Speed * 60
        beltTrafficList = self.Facility.return_consumption().copy()

        # beltTrafficList.append((self.Product,self.Production))  # this ... methodology ... is ... FALSE

        def takeSecond(elem):
            return elem[1]

        beltTrafficList.sort(key=takeSecond, reverse=True)

        n_Adjacent_fact = floor(itemsPerMinute / beltTrafficList[0][1])
        if n_Adjacent_fact < 1:
            n_Adjacent_fact = 1
        return n_Adjacent_fact

    def return_belt_traffic_logistics(self):
        usersettings = self.UserSettings
        belts = usersettings.return_belts()
        nStacks = usersettings.return_piler_stack()

        itemsPerMinute = nStacks * belts.Speed * 60
        beltTrafficList = self.Facility.return_consumption().copy()

        logistics_list = []

        facts_per_product_line = (self.Product, floor(itemsPerMinute / self.Facility.return_production()))
        logistics_list.append(facts_per_product_line)

        for ingredient in beltTrafficList:
            facts_per_ingredient_line = floor(itemsPerMinute / ingredient[1])
            if facts_per_ingredient_line < 1:
                facts_per_ingredient_line = 1
            logistics_list.append((ingredient[0], facts_per_ingredient_line))

        return logistics_list

    def return_calculated_length(self):
        usersettings = self.UserSettings
        return ceil(self.numOfFacilities / self.return_maximum_effective_width(usersettings.return_piler_stack(),
                                                                               usersettings.return_belts()))

    def calculate_number_of_facilities(self):
        productsPerMinutePerFactory = self.Facility.return_production()
        factories_required = ceil(self.ProductionGoal / productsPerMinutePerFactory)
        return factories_required

    def calculate_production(self):
        return self.Facility.return_production() * self.numOfFacilities

    def calculate_by_products(self):
        if getattr(self.Facility.Product, "ByProducts"):
            p = []
            for product in self.Facility.Product.ByProducts:
                p.append((product[0](), 60 * self.Facility.ProductionSpeed * self.numOfFacilities * product[1] / self.Facility.Product.ProductionTime))
            return p

    def calculate_consumption(self):
        #  if hasattr(self.Facility, "return_consumption"):
        #      if callable(self.Facility.return_consumption):
        #          return self.Facility.return_consumption()
        consumption_per_minute = []
        for i in self.Facility.Product.Ingredients:
            if callable(i[0]):
                consumption_per_minute.append((i[0](), i[
                    1] * 60 * self.Facility.ProductionSpeed * self.numOfFacilities / self.Facility.Product.ProductionTime))
            else:
                consumption_per_minute.append((i[0], i[
                    1] * 60 * self.Facility.ProductionSpeed * self.numOfFacilities / self.Facility.Product.ProductionTime))
        return consumption_per_minute

    def calculate_work_consumption(self):
        return self.numOfFacilities * self.Facility.WorkConsumption

    def calculate_idle_consumption(self):
        return self.numOfFacilities * self.Facility.IdleConsumption

    def return_report(self, production_report=True, consumption_report=True, power_report=True, BOM=True, logistics_report=True):
        if hasattr(self, "FactoryTag"):
            s = "{} Factory {}:\n".format(self.Facility.Product.Name, self.FactoryTag)
        else:
            s = "{} Factory:\n".format(self.Facility.Product.Name)

        if production_report:
            s = s + "Production:\n"
            s += "\t{}: {} / min\n".format(self.Product.Name, "{:,.2f}".format(self.Production))
            if getattr(self.Facility.Product, "ByProducts"):
                for toople in self.ByProducts:
                    s += "\t{}: {} / min\n".format(toople[0].Name, "{:,.2f}".format(toople[1]))

        if consumption_report:
            s = s + "Consumption:\n"
            for component, rate in self.Consumption:
                s += "\t{}: {} / min\n".format(component.Name, "{:,.2f}".format(rate))
                if isinstance(component, RawMaterial):
                    if component.Name in self.UserSettings.DefaultRawMaterialSettings:
                        if self.UserSettings.DefaultRawMaterialSettings[component.Name]:
                            new_fact = Factory(component, rate, self.UserSettings, False)
                            facility = new_fact.Facility.Name
                            numOfFacility = new_fact.numOfFacilities
                            s += "\t\t{} {}\n".format(numOfFacility, facility)
                else:
                    new_fact = Factory(component, rate, self.UserSettings, False)
                    facility = new_fact.Facility.Name
                    numOfFacility = new_fact.numOfFacilities
                    s += "\t\t{} {}\n".format(numOfFacility, facility)

        if logistics_report:
            s += "Logistics:\n"
            # s += "\t" + str(self.MaxFactoryEffectiveWidth) + " " + self.Facility.Name + "s / belt line\n"
            # s += "\t where {} is the limiting factor".format(max(self.Consumption)[0].Name)
            logistics_list = self.return_belt_traffic_logistics()
            for toople in logistics_list:
                if callable(toople[0]):
                    comp = toople[0]()
                else:
                    comp = toople[0]
                s += "\t" + str(toople[1]) + " " + self.Facility.Name + "s / {} belt line\n".format(comp.Name)

        if power_report:
            s += "Power consumption:\n"
            s += "\t" + return_prefix_and_val(self.WorkConsumption) + "W Peak\n"
            s += "\t" + return_prefix_and_val(self.IdleConsumption) + "W Idle\n"

        if BOM:
            mk = ["I", "II", "III"]
            s += "Required Facilities:\n"
            s += "\t{} {}s required".format("{:,.2f}".format(self.numOfFacilities), self.Facility.Name)

        if hasattr(self, "Parent"):
            if hasattr(self.Parent, "FactoryTag"):
                s += "\nParent Factory: {}".format(self.Parent.Name + " Factory " + self.Parent.FactoryTag)

        return s


class FactoryChain:
    def __init__(self, user_settings=UserSettings()):
        self.Factories = []
        self.UserSettings = user_settings
        self.SupportingFactories = None

    def add_factory(self, factory):
        self.Factories.append(factory)

    def return_factory_report(self):
        t = ["I", "II", "III", "IV", "V", "VI", "VII"]
        letters = ["G", "F", "E", "D", "C", "B", "A"]
        letter_score = {
            "A": 0,
            "B": 0,
            "C": 0,
            "D": 0,
            "E": 0,
            "F": 0,
            "G": 0
        }
        s = "___________________________________________________________\n"
        s += "_______Dyson Sphere Program Production Calculator V1_______\n"
        s += "___________________________________________________________\n\n"
        s += "___________________________________________________________\n"

        n_fact = 0

        def generate_tag(fact, num):
            # letters = ["G", "F", "E", "D", "C", "B", "A"]
            tier = fact.UserSettings.return_tier(fact.Product)
            tag = letters[tier-1] + str(num)
            return tag

        def layer(fact, S, letter_s, n, ti, letter):
            n += 1
            S += "_____________________Sub Factory #{}_______________________\n".format(n)
            S += "__________________________{}_______________________________\n".format(
                ti[fact.UserSettings.return_tier(fact.Product) - 1])
            letter_s[letter[fact.UserSettings.return_tier(fact.Product) - 1]] += 1
            fact.assign_factory_tag(generate_tag(fact, letter_s[
                letter[fact.UserSettings.return_tier(fact.Product) - 1]]))
            S += fact.return_report()
            S += "\n___________________________________________________________\n"
            if hasattr(fact, "SubFactories"):
                if len(fact.SubFactories) > 0:
                    for sub in fact.SubFactories:
                        S, n = layer(sub, S, letter_s, n, ti, letter)
            return S, n

        for factory in self.Factories:
            n_fact += 1
            s += "_____________________Main Factory #{}_______________________\n".format(self.Factories.index(factory) + 1)
            s += "__________________________{}________________________________\n".format(t[self.UserSettings.return_tier(factory.Product) - 1])
            letter_score[letters[factory.UserSettings.return_tier(factory.Product) - 1]] += 1
            factory.assign_factory_tag(generate_tag(factory, letter_score[letters[factory.UserSettings.return_tier(factory.Product) - 1]]))
            s += factory.return_report()
            s += "\n___________________________________________________________\n"
            if hasattr(factory, "SubFactories"):
                if len(factory.SubFactories) > 0:
                    for sub_factory in factory.SubFactories:
                        s, n_fact = layer(sub_factory, s, letter_score, n_fact, t, letters)

        return s






    def return_consolidated_factory_report(self, include_title=True):
        t = ["I", "II", "III", "IV", "V", "VI", "VII"]
        s = "___________________________________________________________\n"
        if include_title:
            s += "_______Dyson Sphere Program Production Calculator V1_______\n"
            s += "___________________________________________________________\n\n"
            s += "___________________________________________________________\n"

        for factory in self.Factories:
            s += "_____________________Main Factory #{}_______________________\n".format(
                self.Factories.index(factory) + 1)
            s += "__________________________{}________________________________\n".format(
                t[self.UserSettings.return_tier(factory.Product) - 1])
            s += factory.FactoryReport
            s += "\n___________________________________________________________\n"

        for sub_factory in self.SupportingFactories:
            s += "_____________________Sub Factory #{}_______________________\n".format(
                self.SupportingFactories.index(sub_factory) + 1)
            s += "__________________________{}_______________________________\n".format(
                t[self.UserSettings.return_tier(sub_factory.Product) - 1])
            s += sub_factory.FactoryReport
            s += "\n___________________________________________________________\n"

        s += "\n\n"

        consolidated_facility_dict = {}  # Keep track of the factories that produce the same product so that their required facilities may be summed.
        consolidated_facility_keys = []  # List of all the keys to access the dictionary above.

        byproduct_material_production = {}  # Keep track of a sum of all the total byproducts produced by advanced materials.
        byproduct_material_production_keys = []  # List of all the keys to access the dictionary above.

        raw_material_consumption = {}  # Keep track of all the raw materials that are consumed so that mining infrastructure can be sized accordingly.
        raw_material_consumption_keys = []  # List of all the keys to access the dictionary above.

        power_total = 0

        for factory in self.Factories:

            power_total += factory.WorkConsumption  # Account for the full power usage of all factories

            if factory.Facility.Name in consolidated_facility_dict:  # Group factories that produce the same product together
                consolidated_facility_dict[factory.Facility.Name] += factory.numOfFacilities
            else:
                consolidated_facility_keys.append(factory.Facility.Name)
                consolidated_facility_dict[factory.Facility.Name] = factory.numOfFacilities

            if factory.ByProducts is not None:  # Group together all materials produced by all advanced recipes for all factories
                for byproduct in factory.ByProducts:
                    if byproduct.Name in byproduct_material_production:
                        byproduct_material_production[byproduct[0].Name] += byproduct[1]
                    else:
                        byproduct_material_production_keys.append(byproduct[0].Name)
                        byproduct_material_production[byproduct[0].Name] = byproduct[1]

            for consumable in factory.Consumption:
                if issubclass(type(consumable[0]), RawMaterial):
                    if consumable[0].Name in raw_material_consumption:
                        raw_material_consumption_keys.append(consumable[0].Name)
                        raw_material_consumption[consumable[0].Name] += consumable[1]
                    else:
                        raw_material_consumption[consumable[0].Name] = consumable[1]

        consolidated_facility_dict_s = {}
        consolidated_facility_keys_s = []

        for factory in self.SupportingFactories:

            power_total += factory.WorkConsumption  # Account for the full power usage of all factories

            if factory.Facility.Name in consolidated_facility_dict_s:  # Group factories that produce the same product together
                consolidated_facility_dict_s[factory.Facility.Name] += factory.numOfFacilities
            else:
                consolidated_facility_keys_s.append(factory.Facility.Name)
                consolidated_facility_dict_s[factory.Facility.Name] = factory.numOfFacilities

            if factory.ByProducts is not None:  # Group together all materials produced by all advanced recipes for all factories
                for byproduct in factory.ByProducts:
                    if byproduct[0].Name in byproduct_material_production:
                        byproduct_material_production[byproduct[0].Name] += byproduct[1]
                    else:
                        byproduct_material_production_keys.append(byproduct[0].Name)
                        byproduct_material_production[byproduct[0].Name] = byproduct[1]

            for consumable in factory.Consumption:
                if issubclass(type(consumable[0]), RawMaterial):
                    if consumable[0].Name in raw_material_consumption:
                        raw_material_consumption[consumable[0].Name] += consumable[1]
                    else:
                        raw_material_consumption_keys.append(consumable[0].Name)
                        raw_material_consumption[consumable[0].Name] = consumable[1]

        s += "___________________________________________________________\n"
        s += "_______________Factory Chain Specifications_______________\n"
        s += "___________________________________________________________\n\n"
        s += "Total Factory Chain Power Consumption:\n"

        s += "\t" + return_prefix_and_val(power_total) + "W\n\n"

        s += "Total Raw Material Production Rate:\n"
        for key in byproduct_material_production_keys:
            s += "\t" + "{:,.0f} ".format(byproduct_material_production[key]) + key + " / min\n"

        s += "\nTotal Raw Material Consumption Rate:\n"
        for key in raw_material_consumption_keys:
            s += "\t" + "{:,.0f} ".format(raw_material_consumption[key]) + key + " / min\n"

        s += "___________________________________________________________\n"
        s += "______________________Main Factories_______________________\n"
        s += "___________________________________________________________\n"

        for key in consolidated_facility_keys:
            s += "\t{:,.2f} {}s required\n".format(consolidated_facility_dict[key], key)

        s += "___________________________________________________________\n"
        s += "_______________________Sub Factories_______________________\n"
        s += "___________________________________________________________\n"

        for key in consolidated_facility_keys_s:
            s += "\t{:,.2f} {}s required\n".format(consolidated_facility_dict_s[key], key)

        s += "___________________________________________________________\n"
        s += "__________________________END______________________________\n"
        s += "___________________________________________________________\n"
        return s

    def consolidate_supporting_factories(self):
        d, keys = self.__sort_supporting_factories()
        fact_list = []
        for key in keys:
            if len(d[key]) > 1:
                comp = d[key][1].Product
                production_total = 0
                for fact in d[key]:
                    production_total += fact.Production
                fact_list.append(Factory(comp, production_total, self.UserSettings, False))
            else:
                fact_list.append(d[key][0])

        fact_list.sort(key=self.UserSettings.return_tier, reverse=True)

        self.SupportingFactories = fact_list

    def __sort_supporting_factories(self):
        d = {}
        keys = []

        def sort_sub_factories(dic, klavia, factorie):
            if not len(factorie.SubFactories) == 0:
                new_dic = {}
                new_klavia = []
                for fact in factorie.SubFactories:
                    if fact.Name in dic:
                        dic[fact.Name].append(fact)
                    else:
                        klavia.append(fact.Name)
                        dic[fact.Name] = [fact]
                    (new_dic, new_klavia) = sort_sub_factories(dic, klavia, fact)
                return new_dic, new_klavia
            else:
                return dic, klavia

        for fact in self.Factories:
            #  print("Analyzing {} Factory".format(fact.Name))
            d, keys = sort_sub_factories(d, keys, fact)

        return d, keys


def return_prefix_and_val(val):
    prefixes = [

        [-3, "milli", "m"],
        [0, "", ""],
        [3, "kilo", "k"],
        [6, "Mega", "M"],
        [9, "Giga", "G"],
        [12, "Tera", "T"],
        [15, "Peta", "P"],
        [18, "Exa", "E"],
        [21, "Zetta", "Z"],
        [24, "Yotta", "Y"]

    ]

    for p in prefixes:
        x = val / pow(10, p[0])
        if 1000 > x > 1:
            return "{:.2f} {}".format(x,p[2])
    return "{:e} ".format(val)

