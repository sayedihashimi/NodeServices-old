using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NodeServices {
    using PecanWaffle;
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.IO.Compression;
    using System.Reflection;
    using System.Threading;

    public class NodeVsWizard : ProjectWizard {
        public NodeVsWizard() : base() {
            DeletePecanWaffleModuleFromUsersFolder();
            ExtensionInstallDir = (new DirectoryInfo(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)).FullName);
            Properties["ExtensionInstallDir"] = ExtensionInstallDir;
        }

        public override void RunStarted(object automationObject, Dictionary<string, string> replacementsDictionary, Microsoft.VisualStudio.TemplateWizard.WizardRunKind runKind, object[] customParams) {
            EnsurePecanWaffleExtracted();

            base.RunStarted(automationObject, replacementsDictionary, runKind, customParams);
        }
        public override void RunFinished() {
            // set templatesource
            if (string.IsNullOrWhiteSpace(TemplateSource)) {
                TemplateSource = ExtensionInstallDir;
            }

            base.RunFinished();
        }

        protected string PecanWaffleLocalModulePath
        {
            get
            {
                return Path.Combine(ExtensionInstallDir, @"PwModules\");
            }
        }


        // TODO: Improve this
        private void DeletePecanWaffleModuleFromUsersFolder() {
            string expectedPath = @"%userprofile%\Documents\WindowsPowerShell\Modules\pecan-waffle";
            expectedPath = System.Environment.ExpandEnvironmentVariables(expectedPath);
            if (Directory.Exists(expectedPath)) {
                Directory.Delete(expectedPath, true);
            }

            expectedPath = Environment.ExpandEnvironmentVariables(@"%userprofile%\Documents\WindowsPowerShell\Modules\nuget-powershell");
            if (Directory.Exists(expectedPath)) {
                Directory.Delete(expectedPath, true);
            }
        }
        private void EnsurePecanWaffleExtracted() {
            if (!Directory.Exists(PecanWaffleLocalModulePath)) {
                var swDir = new DirectoryInfo(ExtensionInstallDir);
                var foundFiles = swDir.GetFiles("*.nupkg");
                if (foundFiles == null || foundFiles.Length <= 0) {
                    throw new FileNotFoundException(string.Format("Didn't find any files matching TemplateBuilder*.nupkg in [{0}]", swDir.FullName));
                }

                foreach (var file in foundFiles) {
                    var pkgdir = Path.Combine(PecanWaffleLocalModulePath, file.Name);
                    if (!Directory.Exists(pkgdir)) {
                        Directory.CreateDirectory(pkgdir);
                    }
                    ZipFile.ExtractToDirectory(file.FullName, pkgdir);
                }
            }
        }

    }
}
