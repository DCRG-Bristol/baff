import os
import sys
sys.path.insert(0, os.path.abspath('.'))

import sphinxcontrib.matlab
print(sphinxcontrib.matlab)

# -- Project information -----------------------------------------------------
project = 'Binary Aircraft File Format (BAFF)'
author = 'Fintan Healy'
release = '0.1'

# -- General configuration ---------------------------------------------------

extensions = [
    'sphinx.ext.napoleon',          # For Google/NumPy style docstrings
    'sphinx.ext.autodoc',           # For automatic documentation
    'sphinxcontrib.matlab',         # MATLAB domain support
]

# Napoleon settings (tweaked for MATLAB-style documentation)
napoleon_google_docstring = True
napoleon_numpy_docstring = False
napoleon_include_init_with_doc = True
napoleon_include_private_with_doc = False
napoleon_include_special_with_doc = True
napoleon_use_admonition_for_examples = False
napoleon_use_admonition_for_notes = False
napoleon_use_admonition_for_references = False
napoleon_use_ivar = False
napoleon_use_param = True
napoleon_use_rtype = False  # So that return type lines don’t get repeated
napoleon_custom_sections = [('Returns', 'params_style')]

# -- sphinxcontrib-matlabdomain settings ------------------------------------

# Path to your MATLAB source code (absolute or relative to conf.py)
matlab_src_dir = os.path.abspath('../tbx')  # e.g., if source is in ../matlab
primary_domain = 'mat'
matlab_short_links = True
matlab_auto_link = "basic"


# The name of the root module/package (e.g. a folder containing +myPackage)
matlab_keep_package_prefix = True

# -- HTML output -------------------------------------------------------------
html_theme = 'sphinx_rtd_theme'  # or 'sphinx_rtd_theme', 'furo', etc.

def setup(app):
    import sphinxcontrib.matlab
    app.setup_extension('sphinxcontrib.matlab')
