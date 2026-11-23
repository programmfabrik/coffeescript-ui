// Writes the list of the third-party packages the build has put into the
// bundle: name, version, license and the text of the license file of each.
//
// The bundle is checked in (public/cui.min.js), and whoever ships it has to
// name what is inside and reproduce the licenses. Only this build knows that:
// it is the one place where the packages are installed, and the bundle itself
// no longer tells which packages went in. So the list is written next to the
// bundle and checked in with it, and everybody who ships the bundle reads it
// from there instead of keeping a list of their own.
//
// Nothing is listed by hand. A package is in the list when webpack has read a
// file of it for this build: the modules of the JavaScript bundle, what the
// stylesheets import and the files that are copied as they are. That includes
// the copies `gulp thirdparty` puts into src/scss/thirdparty/, which are files
// of a package under another path.

const fs = require('fs');
const path = require('path');

const PLUGIN = 'ThirdpartyPlugin';
const MODULES = 'node_modules';

// Packages whose files are modules of the build but which leave no code of
// their own in what is shipped. css-loader's runtime runs inside the build,
// where it turns a stylesheet into the text that is extracted into the .css
// file; the JavaScript around it is thrown away (not-needed/). A build tool
// that starts to show up and is not named here is listed, which is the safe
// side.
const BUILD_ONLY = new Set([
	'css-loader',
]);

class ThirdpartyPlugin {
	// options.filename: the file to write, relative to the output directory
	// options.copies:   directory that holds copies of package files, as
	//                   <copies>/<package>/...
	constructor(options) {
		this.filename = options.filename;
		this.copies = options.copies ? path.resolve(options.copies) + path.sep : null;
	}

	apply(compiler) {
		const root = compiler.context ? path.resolve(compiler.context, '..') : process.cwd();

		compiler.hooks.afterEmit.tapPromise(PLUGIN, async (compilation) => {
			const packages = new Map();
			const problems = [];

			const add = (dir) => {
				if (packages.has(dir)) {
					return;
				}
				const pkg = readPackage(dir);
				if (!pkg) {
					problems.push(`${path.relative(root, dir)} has no package.json with a name and a version`);
					return;
				}
				packages.set(dir, pkg);
			};

			for (const file of readFiles(compilation)) {
				const dir = this.packageDir(file, root);
				if (dir) {
					add(dir);
				}
			}

			const components = [];
			for (const [dir, pkg] of packages) {
				if (BUILD_ONLY.has(pkg.name)) {
					continue;
				}
				components.push(component(dir, pkg));
			}
			components.sort((a, b) => compare(a.name, b.name) || compare(a.version, b.version));

			if (problems.length > 0) {
				throw new Error(`${PLUGIN}: ${problems.sort().join('; ')}`);
			}

			const out = {
				'//': 'Written by the build (thirdparty-webpack-plugin.js), not by hand: the third-party packages inside cui.js and cui.min.js and the stylesheets.',
				components: components,
			};
			const target = path.join(compiler.options.output.path, this.filename);
			await fs.promises.writeFile(target, JSON.stringify(out, null, '\t') + '\n');
		});
	}

	// packageDir returns the directory of the package a file belongs to, or
	// null for a file of our own.
	packageDir(file, root) {
		const at = file.lastIndexOf(path.sep + MODULES + path.sep);
		if (at >= 0) {
			const base = file.slice(0, at + MODULES.length + 2);
			const parts = file.slice(base.length).split(path.sep);
			const name = parts[0].startsWith('@') ? path.join(parts[0], parts[1]) : parts[0];
			return path.join(base, name);
		}
		if (this.copies && file.startsWith(this.copies)) {
			const name = file.slice(this.copies.length).split(path.sep)[0];
			return path.join(root, MODULES, name);
		}
		return null;
	}
}

// readFiles yields every file whose content went into the output: what the
// modules were built from, which includes what a stylesheet imports, and the
// files that were copied as they are. Not compilation.fileDependencies: that
// has the package.json of every loader as well, which the resolver reads.
function* readFiles(compilation) {
	for (const module of compilation.modules) {
		if (module.resource) {
			yield module.resource.split('?')[0];
		}
		const info = module.buildInfo;
		if (info && info.fileDependencies) {
			yield* info.fileDependencies;
		}
	}
	for (const asset of compilation.getAssets()) {
		if (asset.info.copied && asset.info.sourceFilename) {
			yield path.resolve(compilation.compiler.context, asset.info.sourceFilename);
		}
	}
}

function compare(a, b) {
	return a < b ? -1 : a > b ? 1 : 0;
}

function readPackage(dir) {
	let pkg;
	try {
		pkg = JSON.parse(fs.readFileSync(path.join(dir, 'package.json'), 'utf8'));
	} catch (err) {
		return null;
	}
	if (!pkg.name || !pkg.version) {
		return null;
	}
	return pkg;
}

function component(dir, pkg) {
	return {
		name: pkg.name,
		version: pkg.version,
		license: license(pkg),
		url: url(pkg),
		description: pkg.description || '',
		license_text: licenseText(dir),
	};
}

// license is what package.json declares, as an SPDX expression.
function license(pkg) {
	const one = (l) => (typeof l === 'string' ? l : (l && l.type) || '');
	let declared = '';
	if (Array.isArray(pkg.licenses)) {
		declared = pkg.licenses.map(one).filter(Boolean).join(' OR ');
	} else {
		declared = one(pkg.license);
	}
	return declared.replace(/^\((.*)\)$/, '$1');
}

function url(pkg) {
	if (pkg.homepage) {
		return pkg.homepage;
	}
	const repository = typeof pkg.repository === 'string' ? pkg.repository : (pkg.repository && pkg.repository.url) || '';
	return repository.replace(/^git\+/, '').replace(/^git:\/\//, 'https://').replace(/\.git$/, '');
}

// licenseText is the first license file at the root of the package, by name,
// or '' when the package has none.
function licenseText(dir) {
	const names = fs.readdirSync(dir, { withFileTypes: true })
		.filter((entry) => entry.isFile() && /^(licen[sc]e|copying)/i.test(entry.name))
		.map((entry) => entry.name)
		.sort();
	if (names.length === 0) {
		return '';
	}
	return fs.readFileSync(path.join(dir, names[0]), 'utf8')
		.replace(/^﻿/, '')
		.replace(/\r\n?/g, '\n')
		.replace(/[ \t]+$/gm, '')
		.trim();
}

module.exports = ThirdpartyPlugin;
