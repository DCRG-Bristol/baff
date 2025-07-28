import os
from collections import defaultdict
from pathlib import Path

MATLAB_SRC_DIR = 'tbx'
ROOT_PACKAGE = 'baff'
DOCS_DIR = 'docs'
API_DIR = os.path.join(DOCS_DIR, 'api')
TOP_INDEX_RST = os.path.join(DOCS_DIR, 'index.rst')

# Configuration for handling different types of MATLAB files
FUNCTION_PACKAGES = ['util']  # Packages that contain standalone functions


def is_class_file(filepath):
    """Check if a .m file contains a class definition."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            # Check first non-comment line for classdef
            lines = [line.strip() for line in content.split('\n') if line.strip() and not line.strip().startswith('%')]
            return len(lines) > 0 and lines[0].startswith('classdef')
    except Exception:
        return False


def is_function_file(filepath):
    """Check if a .m file contains a function definition."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            # Check first non-comment line for function
            lines = [line.strip() for line in content.split('\n') if line.strip() and not line.strip().startswith('%')]
            return len(lines) > 0 and lines[0].startswith('function')
    except Exception:
        return False


def find_matlab_items(package_dir):
    """Find all MATLAB classes and functions in +package structure."""
    class_map = defaultdict(set)
    function_map = defaultdict(set)
    seen_class_folders = set()

    for root, dirs, files in os.walk(package_dir):
        rel_path = os.path.relpath(root, package_dir)
        domain_parts = rel_path.split(os.sep) if rel_path != '.' else []
        
        # Check if we're inside a @ClassName folder
        in_class_folder = any(part.startswith('@') for part in domain_parts)
        
        # Build proper package hierarchy
        if rel_path == '.':
            domain = ''
        else:
            # Convert +package/+subpackage to package.subpackage
            # Skip @ClassName parts when building domain
            domain_list = []
            for part in domain_parts:
                if part.startswith('+'):
                    domain_list.append(part[1:])
                # Skip @ClassName parts - they don't contribute to package hierarchy
            domain = '.'.join(domain_list)

        # Skip processing if we're inside a class folder - methods are handled by sphinx
        if in_class_folder:
            continue

        # Handle class folders like @MyClass/
        for d in dirs:
            if d.startswith('@'):
                class_name = d[1:]
                seen_class_folders.add((domain, class_name.lower()))
                class_map[domain].add(class_name)

        # Handle .m files (only if not inside @ClassName folder)
        for file in files:
            if file.endswith('.m') and not file.startswith('.'):
                full_path = os.path.join(root, file)
                item_name = file[:-2]  # Remove '.m'

                if is_class_file(full_path):
                    # Skip if folder-based version already exists
                    if (domain, item_name.lower()) not in seen_class_folders:
                        class_map[domain].add(item_name)
                elif is_function_file(full_path):
                    # Check if this domain should be treated as function package
                    domain_parts_list = domain.split('.') if domain else []
                    if any(func_pkg in domain_parts_list for func_pkg in FUNCTION_PACKAGES):
                        function_map[domain].add(item_name)

    return class_map, function_map


def write_class_rst(subpackage, class_name, package_dir):
    """Generate RST file for a MATLAB class."""
    sub_dir = os.path.join(API_DIR, subpackage.replace('.', os.sep)) if subpackage else API_DIR
    os.makedirs(sub_dir, exist_ok=True)

    rst_path = os.path.join(sub_dir, f'{class_name.lower()}.rst')
    
    # Build full qualified name
    if subpackage:
        full_qual_name = f"+{ROOT_PACKAGE}" + ''.join([f".+{part}" for part in subpackage.split('.')]) + f".{class_name}"
    else:
        full_qual_name = f"+{ROOT_PACKAGE}.{class_name}"

    # Look for README in @ClassName folder
    class_readme_path = find_class_readme_file(package_dir, subpackage, class_name)

    with open(rst_path, 'w', encoding='utf-8') as f:
        f.write(f"{class_name} class\n")
        f.write("=" * (len(class_name) + 7) + "\n\n")
        
        # Include class README content if found
        if class_readme_path:
            include_readme_content(f, class_readme_path)
        
        f.write(f".. mat:autoclass:: {full_qual_name}\n")
        f.write("   :members:\n")
        f.write("   :undoc-members:\n")
        f.write("   :show-inheritance:\n")
    
    return class_name.lower()


def write_function_rst(subpackage, function_name):
    """Generate RST file for a MATLAB function."""
    sub_dir = os.path.join(API_DIR, subpackage.replace('.', os.sep)) if subpackage else API_DIR
    os.makedirs(sub_dir, exist_ok=True)

    rst_path = os.path.join(sub_dir, f'{function_name.lower()}.rst')
    
    # Build full qualified name
    if subpackage:
        full_qual_name = f"+{ROOT_PACKAGE}" + ''.join([f".+{part}" for part in subpackage.split('.')]) + f".{function_name}"
    else:
        full_qual_name = f"+{ROOT_PACKAGE}.{function_name}"

    with open(rst_path, 'w', encoding='utf-8') as f:
        f.write(f"{function_name} function\n")
        f.write("=" * (len(function_name) + 10) + "\n\n")
        f.write(f".. mat:autofunction:: {full_qual_name}\n")
    
    return function_name.lower()


def find_readme_file(package_dir, subpackage):
    """Find readme.rst file in package directory (case-insensitive search)."""
    if subpackage:
        # Convert subpackage to directory path
        sub_path = subpackage.replace('.', os.sep)
        # Convert to +package format
        path_parts = sub_path.split(os.sep)
        package_path = os.path.join(package_dir, *[f'+{part}' for part in path_parts])
    else:
        # Root package
        package_path = package_dir
    
    if not os.path.exists(package_path):
        return None
    
    # Get all files in the directory for case-insensitive matching
    try:
        actual_files = os.listdir(package_path)
    except OSError:
        return None
    
    # Look for readme.rst (case-insensitive)
    for actual_file in actual_files:
        if actual_file.lower() == 'readme.rst':
            return os.path.join(package_path, actual_file)
    
    return None


def find_class_readme_file(package_dir, subpackage, class_name):
    """Find readme.rst file in @ClassName directory (case-insensitive search)."""
    if subpackage:
        # Convert subpackage to directory path
        sub_path = subpackage.replace('.', os.sep)
        # Convert to +package format
        path_parts = sub_path.split(os.sep)
        class_dir = os.path.join(package_dir, *[f'+{part}' for part in path_parts], f'@{class_name}')
    else:
        # Root package
        class_dir = os.path.join(package_dir, f'@{class_name}')
    
    if not os.path.exists(class_dir):
        return None
    
    # Get all files in the @Class directory for case-insensitive matching
    try:
        actual_files = os.listdir(class_dir)
    except OSError:
        return None
    
    # Look for readme.rst (case-insensitive)
    for actual_file in actual_files:
        if actual_file.lower() == 'readme.rst':
            return os.path.join(class_dir, actual_file)
    
    return None


def include_readme_content(f, readme_path):
    """Include readme.rst content in the RST file."""
    try:
        with open(readme_path, 'r', encoding='utf-8') as readme_f:
            content = readme_f.read().strip()
            
        if content:
            f.write("Overview\n")
            f.write("--------\n\n")
            f.write(content)
            f.write("\n\n")
    except Exception as e:
        print(f"⚠️  Warning: Could not read README file {readme_path}: {e}")


def write_subpackage_index(subpackage, class_names, function_names, all_subpackages, package_dir):
    """Generate index RST for a subpackage."""
    sub_dir = os.path.join(API_DIR, subpackage.replace('.', os.sep)) if subpackage else API_DIR
    os.makedirs(sub_dir, exist_ok=True)

    index_path = os.path.join(sub_dir, 'index.rst')
    
    # Determine title
    if subpackage:
        title = f"{ROOT_PACKAGE}.{subpackage} Package"
    else:
        title = f"{ROOT_PACKAGE} Package"
    
    # Find child subpackages
    child_packages = []
    if subpackage:
        # Look for packages that are direct children (one level deeper)
        prefix = subpackage + '.'
        for pkg in all_subpackages:
            if pkg.startswith(prefix):
                remainder = pkg[len(prefix):]
                if '.' not in remainder:  # Direct child, not grandchild
                    child_packages.append(remainder)
    else:
        # For root package, find direct children (no dots in the name)
        for pkg in all_subpackages:
            if pkg and '.' not in pkg:
                child_packages.append(pkg)
    
    child_packages.sort()
    
    # Look for README file
    readme_path = find_readme_file(package_dir, subpackage)
    
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(f"{title}\n")
        f.write("=" * len(title) + "\n\n")
        
        # Include README content if found
        if readme_path:
            include_readme_content(f, readme_path)
        
        # Add subpackages section if any
        if child_packages:
            f.write("Subpackages\n")
            f.write("-----------\n\n")
            f.write(".. toctree::\n")
            f.write("   :maxdepth: 1\n\n")
            for child in child_packages:
                f.write(f"   {child}/index\n")
            f.write("\n")
        
        # Add classes section if any
        if class_names:
            f.write("Classes\n")
            f.write("-------\n\n")
            f.write(".. toctree::\n")
            f.write("   :maxdepth: 1\n\n")
            for name in sorted(class_names):
                f.write(f"   {name}\n")
            f.write("\n")
        
        # Add functions section if any
        if function_names:
            f.write("Functions\n")
            f.write("---------\n\n")
            f.write(".. toctree::\n")
            f.write("   :maxdepth: 1\n\n")
            for name in sorted(function_names):
                f.write(f"   {name}\n")
            f.write("\n")


def write_top_index(subpackages):
    """Generate the main documentation index."""
    with open(TOP_INDEX_RST, 'w', encoding='utf-8') as f:
        f.write("BAFF Documentation\n")
        f.write("==================\n\n")
        f.write("Welcome to the BAFF (Binary Aircraft File Format) documentation.\n\n")
        
        f.write(".. toctree::\n")
        f.write("   :maxdepth: 2\n")
        f.write("   :caption: Contents\n\n")
        f.write("   overview\n")
        f.write("   api_reference\n")


def write_api_reference_index(subpackages):
    """Generate the API reference index page."""
    api_ref_path = os.path.join(DOCS_DIR, 'api_reference.rst')
    
    with open(api_ref_path, 'w', encoding='utf-8') as f:
        f.write("API Reference\n")
        f.write("=============\n\n")
        f.write("Complete API documentation for all BAFF packages.\n\n")
        
        f.write(".. toctree::\n")
        f.write("   :maxdepth: 2\n\n")
        
        # Only include root package and first-level subpackages in API reference TOC
        # Nested packages will appear under their parents automatically
        for sub in sorted(subpackages, key=lambda x: (bool(x), x)):
            if not sub:  # Root package
                f.write("   api/index\n")
            elif '.' not in sub:  # First level subpackages only
                f.write(f"   api/{sub}/index\n")


def write_package_entry_point():
    """Generate entry point files for embedding in parent documentation."""
    # Create a simple baff.rst that can be referenced from parent docs
    entry_point_path = os.path.join(DOCS_DIR, 'baff.rst')
    
    with open(entry_point_path, 'w', encoding='utf-8') as f:
        f.write("BAFF Package\n")
        f.write("============\n\n")
        f.write("Binary Aircraft File Format (BAFF) package documentation.\n\n")
        
        f.write(".. toctree::\n")
        f.write("   :maxdepth: 2\n\n")
        f.write("   overview\n")
        f.write("   api_reference\n")
    
    # Also create a minimal standalone index for iframe embedding
    iframe_index_path = os.path.join(DOCS_DIR, 'standalone.rst')
    
    with open(iframe_index_path, 'w', encoding='utf-8') as f:
        f.write("BAFF Documentation\n")
        f.write("==================\n\n")
        f.write(".. raw:: html\n\n")
        f.write("   <div style=\"margin: -20px;\">\n")
        f.write("   <iframe src=\"../_static/baff_docs/index.html\" width=\"100%\" height=\"800px\" frameborder=\"0\"></iframe>\n")
        f.write("   </div>\n")


def print_summary(class_map, function_map):
    """Print a summary of found items."""
    print(f"\n📊 Documentation Generation Summary:")
    print(f"{'='*40}")
    
    total_classes = sum(len(classes) for classes in class_map.values())
    total_functions = sum(len(functions) for functions in function_map.values())
    
    print(f"Total Classes: {total_classes}")
    print(f"Total Functions: {total_functions}")
    print(f"Total Packages: {len(set(list(class_map.keys()) + list(function_map.keys())))}")
    
    print(f"\nPackage Breakdown:")
    all_packages = set(list(class_map.keys()) + list(function_map.keys()))
    for pkg in sorted(all_packages, key=lambda x: (x.count('.'), x)):
        pkg_name = pkg if pkg else ROOT_PACKAGE
        classes = len(class_map.get(pkg, []))
        functions = len(function_map.get(pkg, []))
        print(f"  📦 {pkg_name}: {classes} classes, {functions} functions")


def write_package_entry_point():
    """Generate a baff.rst file for embedding in parent documentation."""
    entry_point_path = os.path.join(DOCS_DIR, 'baff.rst')
    
    with open(entry_point_path, 'w', encoding='utf-8') as f:
        f.write("BAFF Package\n")
        f.write("============\n\n")
        f.write("Binary Aircraft File Format (BAFF) package documentation.\n\n")
        
        f.write(".. toctree::\n")
        f.write("   :maxdepth: 2\n\n")
        f.write("   overview\n")
        f.write("   api_reference\n")


if __name__ == '__main__':
    print(f"🔍 Scanning MATLAB package: +{ROOT_PACKAGE}")
    package_path = os.path.join(MATLAB_SRC_DIR, f'+{ROOT_PACKAGE}')
    
    if not os.path.exists(package_path):
        print(f"❌ Error: Package directory '{package_path}' not found!")
        exit(1)
    
    class_map, function_map = find_matlab_items(package_path)
    
    # Get all unique subpackages
    all_subpackages = set(list(class_map.keys()) + list(function_map.keys()))
    
    # Generate RST files for each subpackage
    for subpackage in all_subpackages:
        classes = class_map.get(subpackage, set())
        functions = function_map.get(subpackage, set())
        
        # Generate individual RST files
        class_rst_files = [write_class_rst(subpackage, cls, package_path) for cls in classes]
        function_rst_files = [write_function_rst(subpackage, func) for func in functions]
        
        # Generate subpackage index
        write_subpackage_index(subpackage, class_rst_files, function_rst_files, all_subpackages, package_path)
    
    # Generate API reference index
    write_api_reference_index(all_subpackages)
    
    # Generate top-level index
    write_top_index(all_subpackages)
    
    # Generate entry point for embedding in parent docs
    write_package_entry_point()
    
    print_summary(class_map, function_map)
    print(f"\n✅ Documentation structure generated successfully!")
    print(f"📝 Run: sphinx-build -b html {DOCS_DIR} {DOCS_DIR}/_build/html")
    print(f"\n📋 Next steps:")
    print(f"   1. Create '{DOCS_DIR}/overview.rst' with your manual overview content")
    print(f"   2. Add 'readme.rst' files to package directories and @Class folders for automatic inclusion")
    print(f"   3. Build the documentation with Sphinx")
    print(f"   4. For embedding in parent docs, reference '{DOCS_DIR}/baff.rst'")